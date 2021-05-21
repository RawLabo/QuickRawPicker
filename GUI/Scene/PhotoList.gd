extends VBoxContainer

signal thumb_parsed(photo)

var photos = []

func show_folder_images(dir_path):
  $List.clear()
  
  Util.log(dir_path, "open_folder", Util.LogLevel.Verbose)
  
  photos = update_dir(dir_path)
  
  Util.log(photos.size(), "image_files_in_folder")
  
  for photo in photos:
    $List.add_item("")
    Threading.pending_jobs.append(["get_raw_thumb", photo, self])
  
func _on_PhotoList_thumb_parsed(photo):
  var idx = photos.find(photo)
  $List.set_item_text(idx, photo.get_info())
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

func _on_Compare_pressed():
  var selected_photos = get_selected_photos()
  get_parent().emit_signal("photos_received", selected_photos)
  
