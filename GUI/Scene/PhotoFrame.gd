extends Control

class_name PhotoFrame

signal image_parsed(photo)

func vec_int(vec):
  return Vector2(int(vec.x), int(vec.y))
  
func init(w, h, photo):
  rect_min_size = Vector2(w, h)
  $Photo.position = vec_int(rect_min_size / 2)
  
  Threading.pending_jobs.append(["get_raw_image", photo, self, [Settings.bps, false, Settings.auto_bright]])


func _on_PhotoFrame_image_parsed(photo : Photo):
  $Photo.texture = photo.full_texture
