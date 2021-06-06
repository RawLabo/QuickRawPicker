extends VBoxContainer

signal thumb_parsed(photo)
signal photo_selection_changed(photo, selection)
signal photo_mark_changed(photo, mark)

var photos = []

func show_folder_images(dir_path):
  $List.clear()
  
  Util.log(dir_path, "open_folder", Util.LogLevel.Verbose)
  
  photos = update_dir(dir_path)
  
  for photo in photos:
    $List.add_item("")
    Threading.pending_jobs.append(["get_raw_thumb", photo, self])
  
func _on_PhotoList_thumb_parsed(photo):
  var idx = photos.find(photo)
  $List.set_item_text(idx, photo.get_list_info())
  $List.set_item_icon(idx, photo.thumb_texture)
  
func update_dir(dir_path):
  var photos = []
  
  var dir = Directory.new()
  if dir.open(dir_path) == OK:
    dir.list_dir_begin(true)
    var file_name = dir.get_next()
    while file_name != "":
      if not dir.current_is_dir():
        var extension_name = ("." + file_name).rsplit(".", true, 1)[1]
        if extension_name in Settings.extension_filter:
          var file_path = dir_path + "/" + file_name
          if Util.is_windows:
            file_path = file_path.replace("/", "\\")
            
          photos.append(Photo.new(file_path))

      file_name = dir.get_next()
      
  return photos

func get_selected_photos():
  var result = []
  for index in $List.get_selected_items():
    result.append(photos[index])
    
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
