extends Control

func _ready():
  pass
 
func _on_Button2_pressed():
  $Control/Sprite.texture = null
  $Control2/Sprite.texture = null
  $Control3/Sprite.texture = null
  
  ThreadPool.post_jobs([
    ["get_raw_thumb", [get_url(), $Control/Sprite]],
#    ["get_raw_image", [get_url(), $Control/Sprite, 16, false, true]]
    ["get_raw_image", [get_url(), $Control2/Sprite, 16, true, false]],
#    ["get_raw_image", [get_url(), $Control3/Sprite, 16, true, false]]
  ], self, "abc")
  
func abc():
  Util.log("done", "")
  
func get_url():
  if OS.has_feature("editor"):
    return ProjectSettings.globalize_path("res://") + "/020A0088.CR3"
  else:
    return OS.get_executable_path().get_base_dir().plus_file("P1106012.RW2")


  

