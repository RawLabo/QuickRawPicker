extends VBoxContainer

signal photo_parsed(photo)

var photos = []

func show_folder_images(dir_path):
  Util.log(dir_path, "open_folder", Util.LogLevel.Verbose)
  
  photos = update_dir(dir_path)
  
  Util.log(photos.size(), "image_files_in_folder")
  
  for photo in photos:
    Threading.pending_jobs.append(["get_raw_thumb", photo, self])
  
  
func _on_PhotoList_photo_parsed(photo):
  $List.add_icon_item(photo.thumb_texture)
  
  
func update_dir(dir_path):
  var photos = []
  
  var dir = Directory.new()
  if dir.open(dir_path) == OK:
    dir.list_dir_begin(true)
    var file_name = dir.get_next()
    while file_name != "":
      if not dir.current_is_dir():
        var extension_name = file_name.rsplit(".", true, 1)[1]
        if extension_name in Settings.extension_filter:
          var file_path = dir_path + "/" + file_name
          if Util.is_windows:
            file_path = file_path.replace("/", "\\")
            
          photos.append(Photo.new(file_path))

      file_name = dir.get_next()
      
  return photos


