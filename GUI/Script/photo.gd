class_name Photo

var file_path : String
var width : int
var height : int
var aperture : float
var shutter_speed : float
var iso_speed : float
var focal_len : float
var maker : String
var model : String
var lens_info : String

var xmp_rating : int

var thumb_texture : ImageTexture
var full_texture : ImageTexture

var ui_round = 0
var ui_selected := false
var ui_marked := false

const rating_tag = "xmp:Rating="
const xmp_tag = "xmlns:xmp="
const xmp_template = """
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="QuickRawPicker">
 <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about=""
    xmlns:xmp="http://ns.adobe.com/xap/1.0/"
    xmp:Rating="0">
  </rdf:Description>
 </rdf:RDF>
</x:xmpmeta>"""

func _init(path):
  file_path = path
  thumb_texture = ImageTexture.new()
  full_texture = ImageTexture.new()
  update_xmp_rating()
  
func update_xmp_rating():
  var xmp_path =  file_path.substr(0, file_path.find_last(".")) + ".xmp"
  var file = File.new()
  var err = file.open(xmp_path, File.READ)
  if err == 0:
    var content = file.get_as_text()
    var index = content.find(rating_tag)
    if index > -1:
      xmp_rating = content.substr(index + len(rating_tag) + 1, 1).to_int()
    else:
      xmp_rating = 0
  
  file.close()
  
func set_xmp_rating(score):
  xmp_rating = score
  
  var xmp_path =  file_path.substr(0, file_path.find_last(".")) + ".xmp"
  var file = File.new()
  var err = file.open(xmp_path, File.READ_WRITE)
  if err != 0:
    file.open(xmp_path, File.WRITE)
  
  var content = file.get_as_text() if err == 0 else xmp_template
  var score_str = "\"%d\"" % score
    
  var index = content.find(rating_tag)
  if index > -1:
    content = content.substr(0, index + len(rating_tag)) + score_str + content.substr(index + len(rating_tag) + 3)
  else:
    var xmp_index = content.find(xmp_tag)
    content = content.substr(0, xmp_index) + rating_tag + score_str + " " + content.substr(xmp_index)
    
  file.store_string(content)
  file.close()
  
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
  

func get_list_info():
  return "%s\n%d x %d\nF%.1f\n%ss\nISO%1.f\n%.1fmm\n%s %s%s" % [
    file_path,
    width, height,
    aperture,
    shutter_speed,
    iso_speed,
    focal_len,
    maker,
    model,
    " + " + lens_info if len(lens_info) > 0 else ""
  ]
  
func get_bar_info():
  return "F%.1f / %ss / ISO%1.f / %.1fmm / %s" % [
    aperture,
    shutter_speed,
    iso_speed,
    focal_len,
    model + (" + " + lens_info if len(lens_info) > 0 else "")
  ]
