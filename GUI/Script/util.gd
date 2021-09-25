extends Node

onready var Bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()
onready var is_windows = true if OS.get_name() == "Windows" else false
onready var is_macos = true if OS.get_name() == "OSX" else false
onready var log_file = File.new()
onready var Nodes = {
  "Main": get_node("/root/Main"),
  "PhotoList": get_node("/root/Main/PhotoList"),
  "Grid": get_node("/root/Main/Grid")  
}
onready var _f = File.new()
onready var _d = Directory.new()

func _ready():
  var req = HTTPRequest.new()
  add_child(req)
  req.connect("request_completed", self, "latest_release_check")
  req.request("https://api.github.com/repos/qdwang/QuickRawPicker/releases/latest")
  
func latest_release_check(_result, _response_code, _headers, body):
  var content = parse_json(body.get_string_from_utf8())
  if content is Dictionary:
    Settings.latest_version = content.get("tag_name", Settings.version)
    Settings.update_title()
  
func get_file_mod_time(path):
  return _f.get_modified_time(path)

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
  
func path_fix(path):
  return path.replace("/", "\\") if is_windows else path

func copy_file(from, to):
  if is_windows:
    return OS.execute("cmd", ["/C", "echo n | copy /-y \"%s\" \"%s\"" % [path_fix(from), path_fix(to)]])
  else:
    return OS.execute("cp", ["-n", from, to])
