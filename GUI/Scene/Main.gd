extends Control

func _ready():
  pass
 
func _on_Button2_pressed():
  $Control/Sprite.texture = null
  $Control2/Sprite.texture = null
  $Control3/Sprite.texture = null
  
  ThreadPool.post_jobs([
    ["get_raw_image", [get_url(), $Control/Sprite]],
    ["get_raw_image", [get_url(), $Control2/Sprite]],
    ["get_raw_image", [get_url(), $Control3/Sprite]]
  ], self, "abc")
  
func abc():
  printt("done")
  
func get_url():
  if OS.has_feature("editor"):
    return ProjectSettings.globalize_path("res://") + "/P1106012.RW2"
  else:
    return OS.get_executable_path().get_base_dir().plus_file("P1106012.RW2")


  

