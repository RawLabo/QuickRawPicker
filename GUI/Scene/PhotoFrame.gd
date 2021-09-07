extends Control

signal image_parsed(photo)

var scale_options = [
  0,
  1.0,
  1.25,
  1.5,
  2,
  3,
  5,
  7.5,
  10
]

var photo : Photo = null
var scale_index = 0

# shader
var EV = Settings.ev
var gamma = 1.0
var shadow_enable = false
var highlight_enable = false

func select():
  Util.log("frame_select")
  $Selection.modulate.a = 1.0
  selection_style_udpate()
func unselect():
  Util.log("frame_unselect")
  $Selection.modulate.a = 0.5
  selection_style_udpate()
func mark():
  Util.log("frame_mark")
  var alpha = $Selection.modulate.a
  $Selection.modulate = Settings.mark_color
  $Selection.modulate.a = alpha
  selection_style_udpate()
func unmark():
  Util.log("frame_unmark")
  var alpha = $Selection.modulate.a
  $Selection.modulate = Settings.select_color
  $Selection.modulate.a = alpha
  selection_style_udpate()
func selection_style_udpate():
  $InfoLabel.modulate = $Selection.modulate
  $TopContainer.modulate.a = $Selection.modulate.a
  
    
func update_shader():
  if gamma < 0.0:
    gamma = 0.0
    
  $Photo.material.set_shader_param("exposure", EV)
  $Photo.material.set_shader_param("gamma_correction", gamma)
  $Photo.material.set_shader_param("shadow_enable", 1.0 if shadow_enable else 0.0)
  $Photo.material.set_shader_param("highlight_enable", 1.0 if highlight_enable else 0.0)
  $Photo.material.set_shader_param("shadow_thld", Settings.shadow_thld / 100.0)
  $Photo.material.set_shader_param("highlight_thld", Settings.highlight_thld / 100.0)
  $Photo.material.set_shader_param("highlight_one_channel", Settings.highlight_one_channel)
  
  update_top_info()
  
func vec_int(vec):
  return Vector2(int(vec.x), int(vec.y))
    
func init(w, h, input_photo, is_overlay = false):
  # set photo; update rating; set mark
  photo = input_photo
  photo.update_rating()
  if photo.ui_marked:
    mark()
    
  # init frame size and scale params
  rect_min_size = Vector2(w, h)
  scale_options[0] = min(rect_min_size.x / photo.width, rect_min_size.y / photo.height)

  # set $Photo properties
  $Photo.position = vec_int(rect_min_size / 2)
  $Photo.texture = photo.full_texture
  $Photo.scale = Vector2(scale_options[0], scale_options[0])
  
  # set shader
  gamma = Settings.gamma if photo.has_processed() else 1.0
  update_shader()
  
  # set Labels
  $InfoLabel.text = photo.get_bar_info()
  set_info_visibility()
  
  # init AF location
  if photo.focus_loc.size():
    $Photo/FocusPos.position = Vector2(photo.focus_loc[0], photo.focus_loc[1])
  else:
    $Photo/FocusPos.visible = false
  
  # init raw image
  if not photo.has_processed():
    Threading.pending_jobs.append(["get_raw_image", photo, self])
  else:
    call_deferred("update_focus")
    $LoadingLabel.visible = false
    
  # main scene overlay
  if is_overlay:
    mouse_filter = Control.MOUSE_FILTER_STOP
    $TopContainer.visible = false
    $Focus.visible = false
  
func _on_PhotoFrame_image_parsed(_photo):
  $LoadingLabel.visible = false
  set_info_visibility()
  gamma = Settings.gamma
  update_shader()
  
  call_deferred("update_focus")

func set_info_visibility():
  $InfoLabel.visible = Settings.display_info
  $TopContainer.visible = Settings.display_info
  
func toggle_180_rotation():
  $Photo.rotation_degrees += -180 if $Photo.rotation_degrees == 180 else 180
  update_focus()
  
func toggle_focus_point():
  $Focus.visible = not $Focus.visible
  
func update_focus():
  if $Photo/FocusPos.visible:
    $Focus.global_position = vec_int($Photo/FocusPos.global_position)
    
func update_top_info():
  $TopContainer/Size/Value.text = "%d%%" % (scale_options[scale_index] * 100)
  $TopContainer/Exposure/Value.text = "%.1f" % EV
  $TopContainer/Gamma/Value.text = "%.1f" % gamma
  $TopContainer/Rating/RatingCombox.select(photo.rating)

func reset_size():
  rescale(true, 1 if scale_index == 0 else 0)

func rescale(is_scale_up, index = -1, reposition_center = false):
  var prev_scale_index = scale_index
  if index > -1:
    scale_index = index
  else:
    var scale_direction = 1 if is_scale_up else -1
    scale_index += scale_direction
    
    if scale_index < 0:
      scale_index = 0
    elif scale_index > scale_options.size() - 1:
      scale_index = scale_options.size() - 1
    
  var pre_factor = $Photo.scale.x
  var factor = scale_options[scale_index]
  
  $Photo.scale = Vector2(factor, factor)
  if Settings.zoom_at_af_point and $Photo/FocusPos.visible and prev_scale_index == 0 and scale_index == 1:
    reposition((1 if $Photo.rotation_degrees == 180 else -1) * $Photo/FocusPos.position)
  else:
    var pos = rect_min_size / 2 if reposition_center else Util.Nodes["Grid"].cursor_pos_in_frame
    reposition(($Photo.position - pos) * (factor / pre_factor) - ($Photo.position - pos))
  

func reposition(pos):
  if scale_index == 0:
    $Photo.position = vec_int(rect_min_size / 2)
  else:
    var scale = scale_options[scale_index]
    
    var new_pos = $Photo.position + pos
    var left = (photo.width / 2) * scale
    var top = (photo.height / 2) * scale
    var right = rect_min_size.x - (photo.width / 2) * scale
    var bottom = rect_min_size.y - (photo.height / 2) * scale
    
    if new_pos.x > left:
      new_pos.x = left
    if new_pos.x < right:
      new_pos.x = right
      
    if new_pos.y > top:
      new_pos.y = top
    if new_pos.y < bottom:
      new_pos.y = bottom
      
    $Photo.position = vec_int(new_pos)
  
  update_focus()
  update_top_info()


func _on_size_plus_pressed():
  Util.log("_on_size_plus_pressed")
  rescale(true)

func _on_size_minus_pressed():
  Util.log("_on_size_minus_pressed")
  rescale(false)

func _on_exposure_plus_pressed():
  Util.log("_on_exposure_plus_pressed")
  EV += 0.1
  update_shader()

func _on_exposure_minus_pressed():
  Util.log("_on_exposure_minus_pressed")
  EV -= 0.1
  update_shader()
  
func _on_gamma_plus_pressed():
  Util.log("_on_gamma_plus_pressed")
  gamma += 0.1
  update_shader()

func _on_gamma_minus_pressed():
  Util.log("_on_gamma_minus_pressed")
  gamma -= 0.1
  update_shader()

func select_rating_combox(index):
  $TopContainer/Rating/RatingCombox.select(index)
  photo.set_rating(index)
  
func _on_RatingCombox_item_selected(index):
  Util.log("_on_RatingCombox_item_selected", {"index": index})
  photo.set_rating(index)

func toggle_highlight():
  $TopContainer/Highlight.pressed = not $TopContainer/Highlight.pressed
  
func toggle_shadow():
  $TopContainer/Shadow.pressed = not $TopContainer/Shadow.pressed
  
func _on_Highlight_toggled(button_pressed):
  Util.log("_on_Highlight_toggled", {"pressed": button_pressed})
  highlight_enable = button_pressed
  update_shader()

func _on_Shadow_toggled(button_pressed):
  Util.log("_on_Shadow_toggled", {"pressed": button_pressed})
  shadow_enable = button_pressed
  update_shader()

func _on_PhotoFrame_gui_input(event):
  if event is InputEventMouseMotion:
    Util.Nodes["Grid"].cursor_pos_in_frame = event.position
