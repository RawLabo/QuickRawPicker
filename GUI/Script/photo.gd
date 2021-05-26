class_name Photo

var file_path : String
var width : int
var height : int
var aperture : float
var shutter_speed : float
var iso_speed : float
var focal_len : float
var maker : String
var model : String
var lens_info : String

var thumb_texture : ImageTexture
var full_texture : ImageTexture

var ui_round = 0
var ui_is_selected := false
var ui_is_marked := false
var ui_frame

func _init(path):
  file_path = path
  thumb_texture = ImageTexture.new()
  full_texture = ImageTexture.new()
  
func has_processed():
  return full_texture.get_data() != null
  
func get_list_info():
  return "%s\n%d x %d\nF%.1f\n%ss\nISO%1.f\n%.1fmm\n%s %s%s" % [
    file_path,
    width, height,
    aperture,
    shutter_speed,
    iso_speed,
    focal_len,
    maker,
    model,
    " + " + lens_info if len(lens_info) > 0 else ""
  ]
  
func get_bar_info():
  return "F%.1f / %ss / ISO%1.f / %.1fmm / %s" % [
    aperture,
    shutter_speed,
    iso_speed,
    focal_len,
    model + (" + " + lens_info if len(lens_info) > 0 else "")
  ]
