extends HBoxContainer

func _physics_process(_delta):
  if visible:
    $Driver.text = "Driver: %s" % ({0: "GLES3", 1: "GLES2"})[OS.get_current_video_driver()]
    $VMem.text = "VMem: %1.0fm" % (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024 / 1024)
