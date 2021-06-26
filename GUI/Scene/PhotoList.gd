extends VBoxContainer

signal thumb_parsed(photo)
signal photo_selection_changed(photo, selection)
signal photo_mark_changed(photo, mark)

var photos = []

func show_folder_images(dir_path):
  $List.clear()
  
  Util.log(dir_path, "open_folder", Util.LogLevel.Verbose)
  
  update_dir(dir_path)
  
  for photo in photos:
    Threading.pending_jobs.append(["get_raw_thumb", photo, self])
  
func _on_PhotoList_thumb_parsed(photo):
  $List.add_item(photo.get_list_info(), photo.thumb_texture)
  if $List.get_item_count() == photos.size():
    photos.sort_custom(Photo.PhotoSorter, "sort_descending")
    for idx in range(photos.size()):
      $List.set_item_text(idx, photos[idx].get_list_info())
      $List.set_item_icon(idx, photos[idx].thumb_texture)
  
func index_limit(index):
  if index < 0:
    return 0
  elif index > photos.size() - 1:
    return photos.size() - 1
  else:
    return index
    
func show_next():
  var selected_index_lst = $List.get_selected_items()
  var last_index = selected_index_lst[-1] if selected_index_lst.size() > 0 else -1
  var next_index = index_limit(last_index + 1)
  $List.select(next_index)
  _on_Compare_pressed()
  
func show_prev():
  var selected_index_lst = $List.get_selected_items()
  var first_index = selected_index_lst[0] if selected_index_lst.size() > 0 else 1
  var prev_index = index_limit(first_index - 1)
  $List.select(prev_index)
  _on_Compare_pressed()
  
func update_dir(dir_path):
  photos = []
  
  var dir = Directory.new()
  if dir.open(dir_path) == OK:
    dir.list_dir_begin(true)
    var file_name = dir.get_next()
    while file_name != "":
      if not dir.current_is_dir():
        var extension_name = ("." + file_name).rsplit(".", true, 1)[1]
        if extension_name.to_lower() in Settings.extension_filter:
          photos.append(Photo.new(dir_path, file_name))

      file_name = dir.get_next()
      
  photos.invert()
  
func get_selected_photos():
  var result = []
  for index in $List.get_selected_items():
    result.append(photos[index])
    
  return result
  
func get_marked_photos():
  var result = []
  for photo in photos:
    if photo.ui_marked:
      result.append(photo)
    
  return result

var compare_round = 0
func _on_Compare_pressed():
  compare_round += 1
  var selected_photos = get_selected_photos()
  for photo in photos:
    if selected_photos.has(photo):
      photo.ui_round = compare_round
    elif photo.ui_round > 0 and photo.ui_round < compare_round - Settings.cache_round:
      photo.full_texture = ImageTexture.new()
      photo.ui_round = 0
      
  get_parent().emit_signal("photos_received", selected_photos)
  
var with_alt = false
func _on_List_multi_selected(index, selected):
  if with_alt and selected:
    photos[index].toggle_mark()
    
  var selected_photos = get_selected_photos()
  for photo in photos:
    var curr_selected = selected_photos.has(photo)
    if curr_selected != photo.ui_selected:
      photo.toggle_selection()

func clean_cache():
  for photo in photos:
    photo.full_texture = ImageTexture.new()
    photo.ui_round = 0
    
func _on_List_gui_input(event):
  with_alt = event.alt

func _on_PhotoList_photo_mark_changed(photo, mark):
  var idx = photos.find(photo)
  $List.set_item_custom_bg_color(idx, Settings.mark_color if mark else Color.transparent)
  $List.update()

func _on_PhotoList_photo_selection_changed(photo, selection):
  var idx = photos.find(photo)
  if selection:
    $List.select(idx, false)
  else:
    $List.unselect(idx)
