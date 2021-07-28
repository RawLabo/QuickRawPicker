extends Node

onready var Bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()
onready var is_windows = true if OS.get_name() == "Windows" else false
onready var log_file = File.new()
onready var Nodes = {
  "Main": get_node("/root/Main"),
  "PhotoList": get_node("/root/Main/LeftPanel/PhotoList"),
  "Grid": get_node("/root/Main/Grid")  
}
onready var _f = File.new()

func _ready():
  log_file.open("user://logs/debug_info.log", File.WRITE)
  log_file.close()
  
func get_file_mod_time(path):
  return _f.get_modified_time(path)
  
func log(mark, data = null, close_file = true):
  if not log_file.is_open():
    log_file.open("user://logs/debug_info.log", File.READ_WRITE)
  log_file.seek_end()
  log_file.store_string("%s %s\n" % [mark, JSON.print(data) if data else ""])
  if close_file:
    log_file.close()

func float2frac(x):
  var right = x - floor(x)
  var count = 0
  
  var top = 0
  var down = 1
  
  while right > 0.00001 and count < 5:
    var num = 1.0 / right
    var num_left = round(num)
    var num_right = abs(right - 1.0 / num_left)
    
    top += num_left
    down *= num_left
    
    right = num_right
    count += 1

  if top == down:
    top = 1
    
  var gcd_result = gcd(int(top), int(down))
  var frac_part = "%d/%d" % [top / gcd_result, down / gcd_result] 
  if x >= 1:
    return "%d(%s)" % [floor(x), frac_part]
  else:
    return frac_part 

func gcd(a, b):
  if b == 0:
    return a
    
  return gcd(b, a % b)
  
