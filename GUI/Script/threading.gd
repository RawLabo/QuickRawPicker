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

func get_raw_thumb(args):
  var photo : Photo = args[0]
  
  var info = []
  var data_arr = []
  
  Util.Bridge.get_info_with_thumb(photo.file_path, info, data_arr)
  
  if info.size() > 0:
    photo.width = info[0]
    photo.height = info[1]
    photo.aperture = info[2]
    photo.shutter_speed = info[3]
    photo.iso_speed = info[4]
    photo.focal_len = info[5]
    photo.maker = info[6]
    photo.model = info[7]
    photo.lens_info = info[8]
  
    if data_arr.size() > 0:
      var image = Image.new()
      image.load_jpg_from_buffer(data_arr)
      var size = image.get_size()
      var k = size.x / 180
      image.resize(180, size.y / k, Image.INTERPOLATE_CUBIC)
      photo.thumb_texture.create_from_image(image)
      
      if size.y > size.x:
        photo.width = info[1]
        photo.height = info[0]
    else:
      var data = []
      Util.Bridge.get_image_data(photo.file_path, data, 8, true, true)
      
      var image = Image.new()
      image.create_from_data(photo.width / 2, photo.height / 2, false, Image.FORMAT_RGB8, data)
      var size = image.get_size()
      var k = size.x / 180
      image.resize(180, size.y / k, Image.INTERPOLATE_CUBIC)
      photo.thumb_texture.create_from_image(image)
      
      
  call_deferred("thread_end", "thumb_parsed", args)

func get_raw_image(args):
  var photo : Photo = args[0]
  var bps = args[3][0]
  var set_half = args[3][1]
  var auto_bright = args[3][2]
  
  var data = []
  
  Util.Bridge.get_image_data(photo.file_path, data, bps, set_half, auto_bright)
  
  var image = Image.new()
  image.create_from_data(photo.width, photo.height, false, Image.FORMAT_RGBH if bps == 16 else Image.FORMAT_RGB8, data)
  photo.full_texture.create_from_image(image, 1)
  
  call_deferred("thread_end", "image_parsed", args)


func thread_end(signal_name, args):
  var photo : Photo = args[0]
  var thread = args[1]
  var target = args[2]
  
  thread.wait_to_finish()
  working_thread_count -= 1
  
  target.emit_signal(signal_name, photo)
