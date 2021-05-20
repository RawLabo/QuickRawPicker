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

func _init(path):
  file_path = path
  thumb_texture = ImageTexture.new()
  full_texture = ImageTexture.new()
