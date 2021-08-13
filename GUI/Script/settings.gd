extends Node

const auto_bright = false

var bps = 16
var show_thumb_first = true
var cache_round = 2
var output_color = OutputColors.SRGB
var rating_type = RatingType.AdobeXMP
onready var language = get_fixed_locale()
var renderer = "GLES3"
var export_associated = ""
var open_folder = ""
var export_folder = ""
var shadow_thld = 0.1
var highlight_thld = 99.9

var select_color = Color(1, 1, 1)
var mark_color = Color(0.5, 1, 0.3)
var version = "v0.1.11"

onready var project_name = ProjectSettings.get_setting("application/config/name")

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
  ACES = 6
}

func _ready():
  load_settings()
  update_title()
  
func _exit_tree():
  save_settings()
  
func update_title():
  OS.set_window_title("%s %s / %s %s / %s %s" % [project_name, version, tr("display_bit:"), bps, tr("color_space:"), OutputColors.keys()[output_color]])
  
func reset():
  bps = 16
  show_thumb_first = true
  cache_round = 2
  output_color = OutputColors.SRGB
  rating_type = RatingType.AdobeXMP
  language = get_fixed_locale()
  renderer = "GLES3"
  export_associated = ""
  shadow_thld = 0.1
  highlight_thld = 99.9
  save_settings()
  update_title()
  
func save_settings():
  save_renderer()
  
  var file = File.new()
  var content = JSON.print({
    "bps": bps,
    "show_thumb_first": show_thumb_first,
    "cache_round": cache_round,
    "output_color": output_color,
    "rating_type": rating_type,
    "language": language,
    "export_associated": export_associated,
    "open_folder": open_folder,
    "export_folder": export_folder,
    "window_props": [
      OS.window_position.x,
      OS.window_position.y,
      OS.window_size.x,
      OS.window_size.y,
      OS.window_maximized
    ],
    "shadow_thld": shadow_thld,
    "highlight_thld": highlight_thld
  })
  TranslationServer.set_locale(language)
  
  file.open("user://settings.cfg", File.WRITE_READ)
  file.store_string(content)
  file.close()
  
  Util.Nodes["PhotoList"].clean_cache()
  
func load_settings():
  load_renderer()
  
  var file = File.new()
  var err = file.open("user://settings.cfg", File.READ)
  if err == OK:
    var content = file.get_as_text()
    var dict = JSON.parse(content).result
    
    bps = dict.get("bps", 16)
    show_thumb_first = dict.get("show_thumb_first", true)
    cache_round = dict.get("cache_round", 2)
    output_color = dict.get("output_color", OutputColors.SRGB)
    rating_type = dict.get("rating_type", RatingType.AdobeXMP)
    language = dict.get("language", get_fixed_locale())
    export_associated = dict.get("export_associated", "")
    open_folder = dict.get("open_folder", "")
    export_folder = dict.get("export_folder", "")
    shadow_thld = dict.get("shadow_thld", 0.1)
    highlight_thld = dict.get("highlight_thld", 99.9)
    
    # apply settings
    var window_props = dict.get("window_props", [])
    if window_props.size() >= 5:
      if window_props[4]:
        OS.window_maximized = true
      else:
        OS.window_position = Vector2(window_props[0], window_props[1])
        OS.window_size = Vector2(window_props[2], window_props[3])
      
    TranslationServer.set_locale(language)
    
  file.close()

func load_renderer():
  renderer = "GLES3"
  var config = ConfigFile.new()
  var err = config.load("user://config.cfg")
  if err == OK:
    renderer = config.get_value("rendering", "quality/driver/driver_name", "GLES3")
  
func save_renderer():
  var config = ConfigFile.new()
  config.load("user://config.cfg")
  config.set_value("rendering", "quality/driver/driver_name", renderer)
  config.save("user://config.cfg")
    
  
func get_fixed_locale():
  var locale = OS.get_locale()
  var fix_mapping = {
    "en": "en_US",
    "zh": "zh_CN",
    "ja": "ja_JP"  
  }
  if fix_mapping.has(locale):
    return fix_mapping[locale]
  elif Language.has(locale):
    return locale
  else:
    return "en_US"
    
