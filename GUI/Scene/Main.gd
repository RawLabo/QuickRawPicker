extends Control

onready var bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()

func _ready():
  pass
  
func draw_sprite(path, sprite):
  var data_arr = bridge.get_image_data(path)

  var width = data_arr[0]
  var height = data_arr[1]
  var data = data_arr[2]

  var image = Image.new()
  image.create_from_data(width, height, false, Image.FORMAT_RGBH, data)
  var image_texture = ImageTexture.new()
  image_texture.create_from_image(image, 1)

  sprite.texture = image_texture
