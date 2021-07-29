extends Node

const auto_bright = false

var bps = 16
var show_thumb_first = true
var cache_round = 2
var output_color = OutputColors.SRGB
var rating_type = RatingType.XMP
onready var language = get_fixed_locale()
var open_folder = ""
var export_folder = ""

var select_color = Color(1, 1, 1)
var mark_color = Color(0.5, 1, 0.3)
var version = "v0.1.8"

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
  XMP = 0,
  PP3 = 1
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
  
func update_title():
  OS.set_window_title("%s %s / %s %s / %s %s" % [project_name, version, tr("display_bit:"), bps, tr("color_space:"), OutputColors.keys()[output_color]])
  
func reset():
  bps = 16
  show_thumb_first = true
  cache_round = 2
  output_color = OutputColors.SRGB
  rating_type = RatingType.XMP
  language = get_fixed_locale()
  save_settings()
  
func save_settings():
  var file = File.new()
  var content = JSON.print({
    "bps": bps,
    "show_thumb_first": show_thumb_first,
    "cache_round": cache_round,
    "output_color": output_color,
    "rating_type": rating_type,
    "language": language,
    "open_folder": open_folder,
    "export_folder": export_folder
  })
  TranslationServer.set_locale(language)
  
  file.open("user://settings.cfg", File.WRITE_READ)
  file.store_string(content)
  file.close()
  
  Util.Nodes["PhotoList"].clean_cache()
  
func load_settings():
  var file = File.new()
  var err = file.open("user://settings.cfg", File.READ)
  if err == OK:
    var content = file.get_as_text()
    var dict = JSON.parse(content).result
    
    bps = dict.get("bps", 16)
    show_thumb_first = dict.get("show_thumb_first", true)
    cache_round = dict.get("cache_round", 2)
    output_color = dict.get("output_color", OutputColors.SRGB)
    rating_type = dict.get("rating_type", RatingType.XMP)
    language = dict.get("language", get_fixed_locale())
    open_folder = dict.get("open_folder", "")
    export_folder = dict.get("export_folder", "")
    
    TranslationServer.set_locale(language)
    
  file.close()

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
    
