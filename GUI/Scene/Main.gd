extends Control

func _ready():
  OS.window_maximized = true

func show_fullscreen_photo(photo_frame):
  if not $PhotoFrame.visible:
    $PhotoFrame.init($PhotoFrame.rect_size.x, $PhotoFrame.rect_size.y, photo_frame.photo, true)
    $PhotoFrame.gamma = photo_frame.gamma
    $PhotoFrame.EV = photo_frame.EV
    $PhotoFrame.update_shader()
    $PhotoFrame.set_deferred("visible", true)
  
func _input(event):
  if event is InputEventMouseMotion and $Grid.get_child_count() > 0:
    if event.position.x < 20 && $LeftPanel.rect_position.x <= -200:
      $LeftPanel/LeftPanelAni.play("Slide")
    elif event.position.x > 200 && $LeftPanel.rect_position.x == 0:
      $LeftPanel/LeftPanelAni.play_backwards("Slide")
      
  elif event is InputEventKey and event.pressed:
    if event.scancode == KEY_F:
      $PhotoFrame.visible = false
    elif event.scancode == KEY_F11:
      OS.window_fullscreen = not OS.window_fullscreen
