extends Node

onready var core_num = OS.get_processor_count()

var working_thread_count = 0
var pending_jobs = []

func _physics_process(_delta):
  if working_thread_count < core_num and pending_jobs.size() > 0:
    var job = pending_jobs.pop_front()
    
    working_thread_count += 1
    var thread = Thread.new()
    thread.start(self, job[0], [job[1], thread, job[2], job[3] if job.size() > 3 else null])

func export_files(args):
  var photos = args[0]
  var dir = args[3][0]
  var progress_bar = args[3][1]
  
  var directory = Directory.new()
  progress_bar.max_value = photos.size()
  for i in range(photos.size()):
    progress_bar.value = i
    directory.copy(photos[i].file_path, dir + "/" + photos[i].file_name)
    
  call_deferred("thread_end", "file_exported", args)

func get_raw_thumb(args):
  var photo : Photo = args[0]
  var info = []
  var data_arr = []
  
  var file_path = photo.file_path.replace("/", "\\") if Util.is_windows else photo.file_path
  Util.Bridge.get_info_with_thumb(file_path, info, data_arr)
  
  if info.size() > 0:
    photo.width = info[0]
    photo.height = info[1]
    photo.aperture = info[2]
    photo.shutter_speed = info[3]
    photo.iso_speed = info[4]
    photo.focal_len = info[5]
    photo.timestamp = info[6]
    photo.maker = info[7]
    photo.model = info[8]
    photo.lens_info = info[9]
    photo.raw_xmp = info[10]
    
    var image = Image.new()
    var need_half_raw = data_arr.size() == 0
    if not need_half_raw:
      var err = image.load_jpg_from_buffer(data_arr)
      if err != OK:
        err = image.load_bmp_from_buffer(data_arr)
        
      if err == OK:
        var size = image.get_size()
        if size.y > size.x:
          photo.width = info[1]
          photo.height = info[0]
      else:
        need_half_raw = true
        
    if need_half_raw:
      var data = []
      Util.Bridge.get_image_data(photo.file_path, data, 8, true, true, Settings.OutputColors.SRGB)
      image.create_from_data(photo.width / 2, photo.height / 2, false, Image.FORMAT_RGB8, data)
    
    var size = image.get_size()
    var k = size.x / 180
    image.resize(180, size.y / k, Image.INTERPOLATE_CUBIC)
    photo.thumb_texture.create_from_image(image, 0)
      
  call_deferred("thread_end", "thumb_parsed", args)

func get_raw_image(args):
  var photo : Photo = args[0]
  if Settings.show_thumb_first:
    var img = Image.new()
    img.copy_from(photo.thumb_texture.get_data())
    img.resize(photo.width, photo.height, Image.INTERPOLATE_NEAREST)
    photo.full_texture.create_from_image(img, 0)
  
  var data = []
  var file_path = photo.file_path.replace("/", "\\") if Util.is_windows else photo.file_path
  Util.Bridge.get_image_data(file_path, data, Settings.bps, false, Settings.auto_bright, Settings.output_color)
  
  var image = Image.new()
  image.create_from_data(photo.width, photo.height, false, Image.FORMAT_RGBH if Settings.bps == 16 else Image.FORMAT_RGB8, data)
  photo.full_texture.create_from_image(image, 0)
  
  call_deferred("thread_end", "image_parsed", args)


func thread_end(signal_name, args):
  var thread = args[1]
  var target = args[2]
  
  thread.wait_to_finish()
  working_thread_count -= 1
  
  if is_instance_valid(target):
    target.emit_signal(signal_name, args[0])
  
