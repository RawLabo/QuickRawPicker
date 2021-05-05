extends Control

onready var bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()

onready var t1 = Thread.new()
onready var t2 = Thread.new()
onready var t3 = Thread.new()
onready var t4 = Thread.new()
  
func _ready():
  var count = OS.get_processor_count()
  
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


  

