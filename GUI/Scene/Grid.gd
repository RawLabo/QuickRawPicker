extends GridContainer

const PhotoFrameScene = preload("res://Scene/PhotoFrame.tscn")

const pattern = {
  0: [1, 1],
  1: [1, 1],
  2: [2, 1],
  3: [2, 2],
  4: [2, 2],
  5: [3, 2],
  6: [3, 2],
  7: [4, 2],
  8: [4, 2],
  9: [3, 3],
  10: [4, 3],
  11: [4, 3],
  12: [4, 3]
}

func clear_photos():
  for item in get_children():
    item.queue_free()
    
func update_photos(photos):
  clear_photos()
  
  var column_num = 1
  var row_num = 1
  var photos_count = photos.size()
  
  if photos_count in pattern:
    column_num = pattern[photos_count][0]
    row_num = pattern[photos_count][1]
  else:
    column_num = 4
    row_num = 3
    while column_num < 100 && row_num <100:
      if row_num < column_num:
        row_num += 1
      else:
        column_num += 1
        
      if column_num * row_num >= photos_count:
        break
  
  columns = column_num
  var w = int((OS.window_size.x - 200) / columns)
  var h = int(OS.window_size.y / row_num)
  
  for photo in photos:
    var photo_frame = PhotoFrameScene.instance()
    photo_frame.init(w, h, photo)
    add_child(photo_frame)
