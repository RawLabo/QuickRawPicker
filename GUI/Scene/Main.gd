extends Control

signal open_folder_selected(dir_path)
signal photos_received(photos)

func _ready():
  OS.window_maximized = true

func _on_Main_open_folder_selected(dir_path):
  $PhotoList.show_folder_images(dir_path)

func _on_Main_photos_received(photos):
  $Grid.update_photos(photos)
