extends Control

func _ready():
  Util.log("program_started")

func show_fullscreen_photo(photo_frame):
  Util.log("show_fullscreen_photo")
  
  if not $PhotoFrame.visible:
    $PhotoFrame.init($PhotoFrame.rect_size.x, $PhotoFrame.rect_size.y, photo_frame.photo, true)
    $PhotoFrame.gamma = photo_frame.gamma
    $PhotoFrame.EV = photo_frame.EV
    $PhotoFrame.update_shader()
    $PhotoFrame.set_deferred("visible", true)
  
func _input(event):
  if event is InputEventMouseMotion:
    if event.position.x < 100 and $LeftPanel.rect_position.x <= -200:
      $LeftPanel/LeftPanelAni.play("Slide")
    elif event.position.x > 400 and $LeftPanel.rect_position.x == 0 and $Grid.get_child_count() > 0:
      $LeftPanel/LeftPanelAni.play_backwards("Slide")
      
  elif event is InputEventKey and event.pressed:
    if event.scancode == KEY_F:
      Util.log("close_fullscreen_photo")
      $PhotoFrame.visible = false
    elif event.scancode == KEY_F11:
      Util.log("toggle_fullscreen_mode")
      OS.window_fullscreen = not OS.window_fullscreen
    elif event.scancode == KEY_F12:
      Util.log("toggle_sysinfo")
      $SysInfo.visible = not $SysInfo.visible
