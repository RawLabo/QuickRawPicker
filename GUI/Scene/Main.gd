extends Control

onready var bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()

onready var t1 = Thread.new()
onready var t2 = Thread.new()
onready var t3 = Thread.new()
onready var t4 = Thread.new()
  
func _ready():
  var count = OS.get_processor_count()
  
func draw_sprite(path, sprite):
  var data_arr : Array = bridge.get_image_data(path)

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
  var image_texture = ImageTexture.new()
  image_texture.create_from_image(image, 1)

  sprite.texture = image_texture
  $Label.text = str(aperture) + " / " + str(shutter_speed) + " / " + str(iso_speed) + " / " + str(focal_len)  
  
func _on_Button2_pressed():
  t1.start(self, "t1_task")
  
func get_url():
  if OS.has_feature("editor"):
    return ProjectSettings.globalize_path("res://") + "/P1106012.RW2"
  else:
    return OS.get_executable_path().get_base_dir().plus_file("P1106012.RW2")
  
func _on_Button_pressed():
  var exif_info = bridge.get_exif_info(get_url())
  $Label.text = str(exif_info)

func t1_task(userdata):
  draw_sprite(get_url(), $Sprite)


  

