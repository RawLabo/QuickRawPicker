extends Node
onready var bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()

var core_num = 1
var threads = {}
var jobs = []
var jobs_remain = 0
var callback_fn = [null, ""]

func _init():
  core_num = OS.get_processor_count()
  for x in range(core_num):
    var thread = Thread.new()
    threads[thread] = [Semaphore.new()]
    thread.start(self, "thread_handler", thread)

func post_jobs(jobs_input, callback_obj = null, callback_method = ""):
  callback_fn = [callback_obj, callback_method]
  jobs_remain += len(jobs_input)
  jobs.append_array(jobs_input)
  
func _physics_process(_delta):
  if jobs.size() > 0:
    for item in threads.values():
      if len(item) == 1:
        item.push_back(jobs.pop_front())
        item[0].post()
        break
        
  elif callback_fn[0] and jobs_remain == 0:
    callback_fn[0].call(callback_fn[1])
    callback_fn = [null, ""]
  
func thread_handler(thread):
  while true:
    threads[thread][0].wait()
    
    var job = threads[thread][1]
    printt("working", thread.get_id(), job)
    call(job[0], job[1])
    threads[thread].pop_back()
    jobs_remain -= 1
    
func get_raw_image(args):
  var path = args[0]
  var sprite = args[1]
  
  var data_arr = bridge.get_image_data(path)

  var info = data_arr[0]
  var width = info[0]
  var height = info[1]
  var aperture = info[2]
  var shutter_speed = info[3]
  var iso_speed = info[4]
  var focal_len = info[5]

  var data = data_arr[1]
  
  var image = Image.new()
  image.create_from_data(width, height, false, Image.FORMAT_RGBH, data)
  sprite.texture = ImageTexture.new()
  sprite.texture.call_deferred("create_from_image", image, 1)
