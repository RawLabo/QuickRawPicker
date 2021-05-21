class_name Photo

var file_path : String
var width : int
var height : int
var aperture : float
var shutter_speed : float
var iso_speed : float
var focal_len : float
var thumb_texture : ImageTexture
var full_texture : ImageTexture

var ui_marked := false

func _init(path):
  file_path = path
  thumb_texture = ImageTexture.new()
  full_texture = ImageTexture.new()

func get_info():
  return "%s\n%d x %d\nF%.1f\n%ss\nISO%1.f\n%.1fmm" % [
    file_path,
    width, height,
    aperture,
    shutter_speed,
    iso_speed,
    focal_len
  ]
  
