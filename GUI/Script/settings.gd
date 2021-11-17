extends Node

### ===== Definitions ===== ###

const Language = {
  "en_US": 0,
  "zh_CN": 1,
  "ja_JP": 2
}
const extension_filter = [
  "3fr",
  "mdc",
  "ari",
  "mos",
  "arw", "srf", "sr2",
  "mrw",
  "bay",
  "nef", "nrw",
  "braw",
  "orf",
  "cri",
  "pef", "ptx",
  "crw", "cr2", "cr3",
  "pxn",
  "cap", "iiq", "eip",
  "r3d",
  "dcs", "dcr", "drf", "k25", "kdc",
  "raf",
  "dng",
  "raw", "rw2",
  "etf",
  "rwl",
  "fff",
  "rwz",
  "gpr",
  "srw",
  "mef",
  "x3f"
]

enum RatingType {
  AdobeXMP = 0,
  PP3 = 1,
  darktableXMP = 2
}
enum OutputColors {
  RAW = 0,
  SRGB = 1,
  ADOBE = 2,
  WIDE = 3,
  PROPHOTO = 4,
  XYZ = 5,
  ACES = 6,
  DCI_P3 = 7,
  Rec2020 = 8
}
enum SortMethod {
  NameAscending = 0,
  NameDescending = 1,
  ModifiedDateAscending = 2,
  ModifiedDateDescending = 3,
  ExifDateAscending = 4,
  ExifDateDescending = 5
}

const BPS = 16
const SHOW_THUMB_FIRST = true
const CACHE_ROUND = 1
var OUTPUT_COLOR = OutputColors.SRGB
var RATING_TYPE = RatingType.AdobeXMP
var SORT_METHOD = SortMethod.NameDescending
const RENDERER = "GLES3"
const EXPORT_ASSOCIATED = ""
const SHADOW_THLD = 4.5
const HIGHLIGHT_THLD = 99.9
const HIGHLIGHT_ONE_CHANNEL = true
const ZOOM_AT_AF_POINT = true
const DISPLAY_INFO = true
const PIN_MENU = false
const EV = 0.0
const GAMMA = 2.2
const UI_SCALE = 1.0
const XMP_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="QuickRawPicker">
 <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about=""
    xmlns:xmp="http://ns.adobe.com/xap/1.0/"
    xmp:Rating="0">
  </rdf:Description>
 </rdf:RDF>
</x:xmpmeta>"""
const PP3_TEMPLATE = """[General]
Rank=0
"""

const select_color = Color(1, 1, 1)
const mark_color = Color(0.5, 1, 0.3)

func get_fixed_locale():
  var locale = OS.get_locale()
  var fix_mapping = {
    "en": "en_US",
    "zh": "zh_CN",
    "ja": "ja_JP"  
  }
  
  for key in fix_mapping:
    if locale.begins_with(key):
      return fix_mapping[key]
      
  return "en_US"
    
### ===== Definitions above ===== ###


onready var config_cfg_loc = "res://override.cfg" if Util.file_exists("res://override.cfg") else "user://config.cfg"

var config = ConfigFile.new()
var default_section = "custom"


var bps setget bps_set, bps_get
func bps_set(v):
  config.set_value(default_section, "general/bps", v)
func bps_get():
  return config.get_value(default_section, "general/bps", BPS)
  
var show_thumb_first setget show_thumb_first_set, show_thumb_first_get
func show_thumb_first_set(v):
  config.set_value(default_section, "general/show_thumb_first", v)
func show_thumb_first_get():
  return config.get_value(default_section, "general/show_thumb_first", SHOW_THUMB_FIRST)
  
var cache_round setget cache_round_set, cache_round_get
func cache_round_set(v):
  config.set_value(default_section, "general/cache_round", v)
func cache_round_get():
  return config.get_value(default_section, "general/cache_round", CACHE_ROUND)
  
var zoom_at_af_point setget zoom_at_af_point_set, zoom_at_af_point_get
func zoom_at_af_point_set(v):
  config.set_value(default_section, "general/zoom_at_af_point", v)
func zoom_at_af_point_get():
  return config.get_value(default_section, "general/zoom_at_af_point", ZOOM_AT_AF_POINT)
  
var export_associated setget export_associated_set, export_associated_get
func export_associated_set(v):
  config.set_value(default_section, "general/export_associated", v)
func export_associated_get():
  return config.get_value(default_section, "general/export_associated", EXPORT_ASSOCIATED)

var sort_method setget sort_method_set, sort_method_get
func sort_method_set(v):
  config.set_value(default_section, "general/sort_method", v)
func sort_method_get():
  return config.get_value(default_section, "general/sort_method", SORT_METHOD)
  
var ui_scale setget ui_scale_set, ui_scale_get
func ui_scale_set(v):
  config.set_value(default_section, "general/ui_scale", v)
func ui_scale_get():
  return config.get_value(default_section, "general/ui_scale", UI_SCALE)
  
var thread_num setget thread_num_set, thread_num_get
func thread_num_set(v):
  config.set_value(default_section, "general/thread_num", v)
func thread_num_get():
  return config.get_value(default_section, "general/thread_num", OS.get_processor_count())

var language setget language_set, language_get
func language_set(v):
  config.set_value(default_section, "general/language", v)
  TranslationServer.set_locale(v)
func language_get():
  return config.get_value(default_section, "general/language", get_fixed_locale())

  
  
var output_color setget output_color_set, output_color_get
func output_color_set(v):
  config.set_value(default_section, "rendering/output_color", v)
func output_color_get():
  return config.get_value(default_section, "rendering/output_color", OUTPUT_COLOR)
  
var shadow_thld setget shadow_thld_set, shadow_thld_get
func shadow_thld_set(v):
  config.set_value(default_section, "rendering/shadow_thld", v)
func shadow_thld_get():
  return config.get_value(default_section, "rendering/shadow_thld", SHADOW_THLD)
  
var highlight_thld setget highlight_thld_set, highlight_thld_get
func highlight_thld_set(v):
  config.set_value(default_section, "rendering/highlight_thld", v)
func highlight_thld_get():
  return config.get_value(default_section, "rendering/highlight_thld", HIGHLIGHT_THLD)

var highlight_one_channel setget highlight_one_channel_set, highlight_one_channel_get
func highlight_one_channel_set(v):
  config.set_value(default_section, "rendering/highlight_one_channel", v)
func highlight_one_channel_get():
  return config.get_value(default_section, "rendering/highlight_one_channel", HIGHLIGHT_ONE_CHANNEL)

var ev setget ev_set, ev_get
func ev_set(v):
  config.set_value(default_section, "rendering/ev", v)
func ev_get():
  return config.get_value(default_section, "rendering/ev", EV)
  
var gamma setget gamma_set, gamma_get
func gamma_set(v):
  config.set_value(default_section, "rendering/gamma", v)
func gamma_get():
  return config.get_value(default_section, "rendering/gamma", GAMMA)

var renderer setget renderer_set, renderer_get
func renderer_set(v):
  if v == RENDERER:
    config.erase_section_key("rendering", "quality/driver/driver_name")
  else:
    config.set_value("rendering", "quality/driver/driver_name", v)
func renderer_get():
  return config.get_value("rendering", "quality/driver/driver_name", RENDERER)
  
  
var rating_type setget rating_type_set, rating_type_get
func rating_type_set(v):
  config.set_value(default_section, "rating/rating_type", v)
func rating_type_get():
  return config.get_value(default_section, "rating/rating_type", RATING_TYPE)

var xmp_template setget xmp_template_set, xmp_template_get
func xmp_template_set(v):
  config.set_value(default_section, "rating/xmp_template", v)
func xmp_template_get():
  return config.get_value(default_section, "rating/xmp_template", XMP_TEMPLATE)
  
var pp3_template setget pp3_template_set, pp3_template_get
func pp3_template_set(v):
  config.set_value(default_section, "rating/pp3_template", v)
func pp3_template_get():
  return config.get_value(default_section, "rating/pp3_template", PP3_TEMPLATE)
  
  
  
var display_info setget display_info_set, display_info_get
func display_info_set(v):
  config.set_value(default_section, "ui/display_info", v)
func display_info_get():
  return config.get_value(default_section, "ui/display_info", DISPLAY_INFO)
  
var pin_menu setget pin_menu_set, pin_menu_get
func pin_menu_set(v):
  config.set_value(default_section, "ui/pin_menu", v)
func pin_menu_get():
  return config.get_value(default_section, "ui/pin_menu", PIN_MENU)



var open_folder setget open_folder_set, open_folder_get
func open_folder_set(v):
  config.set_value(default_section, "background/open_folder", v)
func open_folder_get():
  return config.get_value(default_section, "background/open_folder", "")

var export_folder setget export_folder_set, export_folder_get
func export_folder_set(v):
  config.set_value(default_section, "background/export_folder", v)
func export_folder_get():
  return config.get_value(default_section, "background/export_folder", "")
  

func load_config():
  config = ConfigFile.new()
  var err = config.load(config_cfg_loc)
  if Util.file_exists(config_cfg_loc) and err != OK:
    OS.alert(tr("config_damaged"))

func set_window_pos():
  config.set_value(default_section, "ui/window/position/x", OS.window_position.x)
  config.set_value(default_section, "ui/window/position/y", OS.window_position.y)
  config.set_value(default_section, "ui/window/size/x", OS.window_size.x)
  config.set_value(default_section, "ui/window/size/y", OS.window_size.y)
  config.set_value(default_section, "ui/window/maximized", OS.window_maximized)

func apply_configs():
  var pos_x = config.get_value(default_section, "ui/window/position/x", OS.window_position.x)
  var pos_y = config.get_value(default_section, "ui/window/position/y", OS.window_position.y)
  var size_x = config.get_value(default_section, "ui/window/size/x", OS.window_size.x)
  var size_y = config.get_value(default_section, "ui/window/size/y", OS.window_size.y)
  OS.window_maximized = config.get_value(default_section, "ui/window/maximized", OS.window_maximized)
  
  if not OS.window_maximized:
    OS.window_position = Vector2(pos_x, pos_y)
    OS.window_size = Vector2(size_x, size_y)
    
  language_set(language_get())
  
func _ready():
  load_config()
  legacy_settings_recovery()
  apply_configs()

func _exit_tree():
  set_window_pos()
  save_config()
  
func reset():
  bps_set(BPS)
  show_thumb_first_set(SHOW_THUMB_FIRST)
  cache_round_set(CACHE_ROUND)
  output_color_set(OUTPUT_COLOR)
  rating_type_set(RATING_TYPE)
  sort_method_set(SORT_METHOD)
  language_set(get_fixed_locale())
  renderer_set(RENDERER)
  export_associated_set(EXPORT_ASSOCIATED)
  shadow_thld_set(SHADOW_THLD)
  highlight_thld_set(HIGHLIGHT_THLD)
  highlight_one_channel_set(HIGHLIGHT_ONE_CHANNEL)
  zoom_at_af_point_set(ZOOM_AT_AF_POINT)
  display_info_set(DISPLAY_INFO)
  pin_menu_set(PIN_MENU)
  ev_set(EV)
  gamma_set(GAMMA)
  ui_scale_set(UI_SCALE)
  xmp_template_set(XMP_TEMPLATE)
  pp3_template_set(PP3_TEMPLATE)
  thread_num_set(OS.get_processor_count())
  
  save_config()
  
func save_config(clean_cache = true):
  config.save(config_cfg_loc)
  Util.update_title()
  
  if clean_cache:
    Util.Nodes["PhotoList"].clean_cache()
    
func legacy_settings_recovery():
  renderer_set(renderer_get())
  
  var legacy_path = "user://settings.cfg"
  if not Util.file_exists(legacy_path):
    return
    
  var file = File.new()
  var err = file.open(legacy_path, File.READ)
  if err == OK:
    var content = file.get_as_text()
    var dict = JSON.parse(content).result
    file.close()
    
    bps_set(dict.get("bps", BPS))
    show_thumb_first_set(dict.get("show_thumb_first", SHOW_THUMB_FIRST))
    cache_round_set(dict.get("cache_round", CACHE_ROUND))
    output_color_set(dict.get("output_color", OUTPUT_COLOR))
    rating_type_set(dict.get("rating_type", RATING_TYPE))
    sort_method_set(dict.get("sort_method", SORT_METHOD))
    language_set(dict.get("language", get_fixed_locale()))
    export_associated_set(dict.get("export_associated", EXPORT_ASSOCIATED))
    open_folder_set(dict.get("open_folder", ""))
    export_folder_set(dict.get("export_folder", ""))
    display_info_set(dict.get("display_info", DISPLAY_INFO))
    pin_menu_set(dict.get("pin_menu", PIN_MENU))
    shadow_thld_set(dict.get("shadow_thld", SHADOW_THLD))
    highlight_thld_set(dict.get("highlight_thld", HIGHLIGHT_THLD))
    highlight_one_channel_set(dict.get("highlight_one_channel", HIGHLIGHT_ONE_CHANNEL))
    zoom_at_af_point_set(dict.get("zoom_at_af_point", ZOOM_AT_AF_POINT))
    ev_set(dict.get("ev", EV))
    gamma_set(dict.get("gamma", GAMMA))
    ui_scale_set(dict.get("ui_scale", UI_SCALE))
    xmp_template_set(dict.get("xmp_template", XMP_TEMPLATE))
    pp3_template_set(dict.get("pp3_template", PP3_TEMPLATE))
    thread_num_set(dict.get("thread_num", OS.get_processor_count()))
    
    var window_props = dict.get("window_props", [])
    if window_props.size() >= 5:
      if window_props[4]:
        OS.window_maximized = true
      else:
        OS.window_position = Vector2(window_props[0], window_props[1])
        OS.window_size = Vector2(window_props[2], window_props[3])
        
    save_config(false)
    Util.file_remove(legacy_path)
