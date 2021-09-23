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
  
func is_dialog_open():
  return $MenuWrapper/Menu.is_settings_dialog_open() or $MenuWrapper/Menu.is_file_dialog_open()

func progress_init(max_v, title = ""):
  if max_v > 0:
    $Progress/Title.text = title
    $Progress/Bar.max_value = max_v
    $Progress/Bar.value = 0
    $Progress.visible = true
  
func progress_set(v):
  $Progress/Bar.value = v
  if v >= $Progress/Bar.max_value:
    $Progress.visible = false
  
func _input(event):
  if event is InputEventMouseMotion:
    if event.position.x < 100 and not $PhotoList.visible:
      $PanelAni.play("FadeIn")
    elif event.position.x > 300 and $PhotoList.visible and $Grid.get_child_count() > 0:
      $PanelAni.play("FadeOut")
      
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
