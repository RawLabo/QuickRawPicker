extends Node

onready var mutex = Mutex.new()
onready var core_num = OS.get_processor_count()

var working_thread_count = 0
var pending_jobs = []

func _ready():
  pass

func _physics_process(_delta):
  if working_thread_count < core_num and pending_jobs.size() > 0:
    var job = pending_jobs.pop_front()
    
    working_thread_count += 1
    var thread = Thread.new()
    thread.start(self, job[0], [job[1], thread, job[2]])

func get_raw_thumb(args):
  var photo : Photo = args[0]
  var thread = args[1]
  
  var info = []
  var data_arr = []
  
  Util.Bridge.get_info_with_thumb(photo.file_path, info, data_arr)
  
  photo.width = info[0]
  photo.height = info[1]
  photo.aperture = info[2]
  photo.shutter_speed = info[3]
  photo.iso_speed = info[4]
  photo.focal_len = info[5]
  
  var image = Image.new()
  image.load_jpg_from_buffer(data_arr)
  var size = image.get_size()
  var k = size.x / 180
  image.resize(180, size.y / k, Image.INTERPOLATE_CUBIC)
  photo.thumb_texture.create_from_image(image)
  
  call_deferred("thread_end", args)


func thread_end(args):
  var photo : Photo = args[0]
  var thread = args[1]
  var target = args[2]
  
  thread.wait_to_finish()
  working_thread_count -= 1
  
  target.emit_signal("photo_parsed", photo)
