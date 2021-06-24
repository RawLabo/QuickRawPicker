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
var gamma = 1.0
var EV = 0
var scale_index = 0
var highlight_draw = 0.0
var shadow_draw = 0.0

func select():
  $TopContainer/Selection.color.a = 1.0
func unselect():
  $TopContainer/Selection.color.a = 0.2
func mark():
  var alpha = $TopContainer/Selection.color.a
  $TopContainer/Selection.color = Settings.mark_color
  $TopContainer/Selection.color.a = alpha
func unmark():
  var alpha = $TopContainer/Selection.color.a
  $TopContainer/Selection.color = Settings.select_color
  $TopContainer/Selection.color.a = alpha
  
func update_shader():
  if gamma < 0.0:
    gamma = 0.0
    
  if shadow_draw < 0:
    shadow_draw = 0
  elif shadow_draw > 1.0:
    shadow_draw = 1.0
    
  if highlight_draw < 0:
    highlight_draw = 0
  elif highlight_draw > 1.0:
    highlight_draw = 1.0
    
  $Photo.material.set_shader_param("exposure", EV)
  $Photo.material.set_shader_param("gamma_correction", gamma)
  $Photo.material.set_shader_param("shadow_draw", shadow_draw)
  $Photo.material.set_shader_param("highlight_draw", highlight_draw)
  
  update_top_info()
  
func vec_int(vec):
  return Vector2(int(vec.x), int(vec.y))
    
func init(w, h, input_photo, is_overlay = false):
  photo = input_photo
  photo.update_rating()
  if photo.ui_marked:
    mark()
    
  rect_min_size = Vector2(w, h)
  scale_options[0] = min(rect_min_size.x / photo.width, rect_min_size.y / photo.height)
  
  $Photo.position = vec_int(rect_min_size / 2)
  $Photo.texture = photo.full_texture
  $Photo.scale = Vector2(scale_options[0], scale_options[0])
  
  gamma = 2.6 if photo.has_processed() and not Settings.auto_bright else 1.0
  update_shader()
  
  $InfoLabel.text = photo.get_bar_info()
  
  if not photo.has_processed():
    Threading.pending_jobs.append(["get_raw_image", photo, self])
  else:
    $LoadingLabel.visible = false
    $TopContainer.visible = true
    
  if is_overlay:
    mouse_filter = Control.MOUSE_FILTER_STOP
    $TopContainer.visible = false
  

func _on_PhotoFrame_image_parsed(_photo):
  $LoadingLabel.visible = false
  $TopContainer.visible = true
  gamma = 2.6 if not Settings.auto_bright else 1.0
  update_shader()

func update_top_info():
  $TopContainer/Size/Value.text = "%d%%" % (scale_options[scale_index] * 100)
  $TopContainer/Exposure/Value.text = "%.1f" % EV
  $TopContainer/Gamma/Value.text = "%.1f" % gamma
  $TopContainer/Rating/RatingCombox.select(photo.rating)

func reset_size():
  rescale(true, 1 if scale_index == 0 else 0)

func rescale(is_scale_up, index = -1):
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
  
  reposition(($Photo.position - rect_min_size / 2) * (factor / pre_factor - 1))
  

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
  
  update_top_info()


func _on_size_plus_pressed():
  rescale(true)

func _on_size_minus_pressed():
  rescale(false)

func _on_exposure_plus_pressed():
  EV += 0.1
  update_shader()

func _on_exposure_minus_pressed():
  EV -= 0.1
  update_shader()
  
func _on_gamma_plus_pressed():
  gamma += 0.1
  update_shader()

func _on_gamma_minus_pressed():
  gamma -= 0.1
  update_shader()

func select_rating_combox(index):
  $TopContainer/Rating/RatingCombox.select(index)
  photo.set_rating(index)
  
func _on_RatingCombox_item_selected(index):
  photo.set_rating(index)

func toggle_highlight():
  $TopContainer/Highlight.pressed = not $TopContainer/Highlight.pressed
  
func toggle_shadow():
  $TopContainer/Shadow.pressed = not $TopContainer/Shadow.pressed
  
func _on_Highlight_toggled(button_pressed):
  highlight_draw = 1.0 if button_pressed else 0.0
  update_shader()

func _on_Shadow_toggled(button_pressed):
  shadow_draw = 1.0 if button_pressed else 0.0
  update_shader()


func _on_PhotoFrame_gui_input(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
    visible = false
