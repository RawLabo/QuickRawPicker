class_name Photo

var file_path : String
var file_name : String
var file_mod_time : int
var width : int
var height : int
var aperture : float
var shutter_speed : float
var shutter_speed_str : String
var iso_speed : float
var focal_len : float
var timestamp : int
var maker : String
var model : String
var lens_info : String
var raw_xmp : String
var focus_loc : Array

var rating : int = 0

var thumb_texture : ImageTexture
var full_texture : ImageTexture

var ui_selected := false
var ui_marked := false

const old_xmp_rating_tag = "xmp:Rating>"
const xmp_rating_tag = "xmp:Rating="
const xmp_tag = "xmlns:xmp="
const xmp_template = """<?xml version="1.0" encoding="UTF-8"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="QuickRawPicker">
 <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about=""
    xmlns:xmp="http://ns.adobe.com/xap/1.0/"
    xmp:Rating="0">
  </rdf:Description>
 </rdf:RDF>
</x:xmpmeta>"""
const pp3_rating_tag = "Rank="
const pp3_template = """
[General]
Rank=0
"""

class PhotoSorter:
  static func ExifDateDescending(a, b):
    return a.timestamp > b.timestamp
    
  static func ExifDateAscending(a, b):
    return a.timestamp < b.timestamp
    
  static func ModifiedDateDescending(a, b):
    return a.file_mod_time > b.file_mod_time
    
  static func ModifiedDateAscending(a, b):
    return a.file_mod_time < b.file_mod_time
    
  static func NameDescending(a, b):
    return a.file_name > b.file_name
  
  static func NameAscending(a, b):
    return a.file_name < b.file_name
    
func _init(dir_path, name):
  file_name = name
  file_path = Util.path_fix(dir_path + "/" + file_name)
  file_mod_time = Util.get_file_mod_time(file_path)
  
  thumb_texture = ImageTexture.new()
  full_texture = ImageTexture.new()
  
func get_buffer():
  var file = File.new()
  var err = file.open(file_path, File.READ)
  var result = file.get_buffer(file.get_len()) if err == OK else []
  file.close()
  return result
  
func update_rating():
  rating = get_xmp_rating(raw_xmp)
  if Settings.rating_type == Settings.RatingType.PP3:
    update_pp3_rating()
  else:
    update_xmp_rating()
    
    
func get_xmp_rating(content):
  var index1 = content.find(xmp_rating_tag)
  if index1 > -1:
    return content.substr(index1 + len(xmp_rating_tag) + 1, 1).to_int()
    
  var index2 = content.find(old_xmp_rating_tag)
  if index2 > -1:
    return content.substr(index2 + len(old_xmp_rating_tag), 1).to_int()
    
  return 0
  
func get_xmp_path():
  if Settings.rating_type == Settings.RatingType.darktableXMP:
    return file_path + ".xmp"
  else:
    return file_path.substr(0, file_path.find_last(".")) + ".xmp"
  
func update_xmp_rating():
  var xmp_path = get_xmp_path()
  var file = File.new()
  var err = file.open(xmp_path, File.READ)
  if err == OK:
    var content = file.get_as_text()
    rating = get_xmp_rating(content)
      
  file.close()
    
func set_xmp_rating(score):
  rating = score
  
  var xmp_path = get_xmp_path()
  var file = File.new()
  var err = file.open(xmp_path, File.READ_WRITE)
  if err != 0:
    file.open(xmp_path, File.WRITE)
  
  var content = file.get_as_text() if err == 0 else xmp_template
  var score_str = "\"%d\"" % score
    
  var index1 = content.find(xmp_rating_tag)
  var index2 = content.find(old_xmp_rating_tag)
  if index1 > -1:
    var tag_len = len(xmp_rating_tag)
    content = content.substr(0, index1 + tag_len) + score_str + content.substr(index1 + tag_len + 3)
  elif index2 > -1:
    var tag_len = len(old_xmp_rating_tag)
    content = content.substr(0, index2 + tag_len) + str(score) + content.substr(index2 + tag_len + 1)
  else:
    var xmp_index = content.find(xmp_tag)
    content = content.substr(0, xmp_index) + xmp_rating_tag + score_str + " " + content.substr(xmp_index)
    
  file.store_string(content)
  file.close()

func update_pp3_rating():
  var pp3_path = file_path + ".pp3"
  var file = File.new()
  var err = file.open(pp3_path, File.READ)
  if err == OK:
    var content = file.get_as_text()
    var index = content.find(pp3_rating_tag)
    if index > -1:
      rating = content.substr(index + len(pp3_rating_tag), 1).to_int()
  
  file.close()
  
func set_pp3_rating(score):
  rating = score
  
  var pp3_path = file_path + ".pp3"
  var file = File.new()
  var err = file.open(pp3_path, File.READ_WRITE)
  if err != OK:
    file.open(pp3_path, File.WRITE)
    
  var content = file.get_as_text() if err == OK else pp3_template
      
  var index = content.find(pp3_rating_tag)
  if index > -1:
    content = content.substr(0, index + len(pp3_rating_tag)) + str(score) + content.substr(index + len(pp3_rating_tag) + 1)

  file.store_string(content)
  file.close()
  
func set_rating(score):
  if Settings.rating_type == Settings.RatingType.PP3:
    set_pp3_rating(score)
  else:
    set_xmp_rating(score)
  
func has_processed():
  return full_texture.get_data() != null

func select():
  ui_selected = true
  emit_selection_change()
func unselect():
  ui_selected = false
  emit_selection_change()
func toggle_selection():
  ui_selected = not ui_selected
  emit_selection_change()
  
func mark():
  ui_marked = true
  emit_mark_change()
func unmark():
  ui_marked = false
  emit_mark_change()
func toggle_mark():
  ui_marked = not ui_marked
  emit_mark_change()
  
  
func emit_selection_change():
  Util.Nodes["PhotoList"].emit_signal("photo_selection_changed", self, ui_selected)
  Util.Nodes["Grid"].emit_signal("photo_selection_changed", self, ui_selected)

func emit_mark_change():
  Util.Nodes["PhotoList"].emit_signal("photo_mark_changed", self, ui_marked)
  Util.Nodes["Grid"].emit_signal("photo_mark_changed", self, ui_marked)
  
func get_datetime():
  var time = OS.get_datetime_from_unix_time(timestamp + OS.get_time_zone_info()["bias"] / 60 * 3600)
  return "%d-%02d-%02d %02d:%02d" % [time["year"], time["month"], time["day"], time["hour"], time["minute"]]

func get_list_info():
  return " %d x %d\nF%.1f   %ss   ISO%1.f\n%.1fmm\n%s %s%s\n%s\n%s" % [
    width, height,
    aperture,
    shutter_speed_str,
    iso_speed,
    focal_len,
    maker,
    model,
    " + " + lens_info if len(lens_info) > 0 else "",
    get_datetime(),
    file_name
  ]
  
func get_bar_info():
  return "%s, F%.1f, %ss, ISO%1.f, %.1fmm, %s" % [
    file_name,
    aperture,
    shutter_speed_str,
    iso_speed,
    focal_len,
    model + (" + " + lens_info if len(lens_info) > 0 else "")
  ]
