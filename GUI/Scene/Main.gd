extends Control

signal open_folder_selected(dir_path)
signal photos_received(photos)
signal fullscreen_photo_received(photo_frame)

func _ready():
  OS.window_maximized = true

func _on_Main_open_folder_selected(dir_path):
  $PhotoList.show_folder_images(dir_path)

func _on_Main_photos_received(photos):
  $Grid.update_photos(photos)

func _on_Main_fullscreen_photo_received(photo_frame):
  if not $PhotoFrame.visible:
    $PhotoFrame.init($PhotoFrame.rect_size.x, $PhotoFrame.rect_size.y, photo_frame.photo, true)
    $PhotoFrame.gamma = photo_frame.gamma
    $PhotoFrame.EV = photo_frame.EV
    $PhotoFrame.update_shader()
    $PhotoFrame.set_deferred("visible", true)
  
func _input(event):
  if event is InputEventKey and event.pressed and event.scancode == KEY_F:
    $PhotoFrame.visible = false
