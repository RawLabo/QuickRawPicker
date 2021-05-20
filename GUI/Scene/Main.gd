extends Control

signal open_folder_selected(dir_path)

func _ready():
  OS.window_maximized = true
  
func _on_Main_open_folder_selected(dir_path):
  $PhotoList.show_folder_images(dir_path)
