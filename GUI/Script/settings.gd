extends Node

const BPS = 16
const SHOW_THUMB_FIRST = true
const CACHE_ROUND = 2
var OUTPUT_COLOR = OutputColors.SRGB
var RATING_TYPE = RatingType.AdobeXMP
const RENDERER = "GLES3"
const EXPORT_ASSOCIATED = ""
const SHADOW_THLD = 4.5
const HIGHLIGHT_THLD = 99.9
const HIGHLIGHT_ONE_CHANNEL = true
const ZOOM_AT_AF_POINT = true
const EV = 0.0
const GAMMA = 2.2

var bps = BPS
var show_thumb_first = SHOW_THUMB_FIRST
var cache_round = CACHE_ROUND
var output_color = OUTPUT_COLOR
var rating_type = RATING_TYPE
var renderer = RENDERER
var export_associated = EXPORT_ASSOCIATED
var open_folder = ""
var export_folder = ""
var shadow_thld = SHADOW_THLD
var highlight_thld = HIGHLIGHT_THLD
var highlight_one_channel = HIGHLIGHT_ONE_CHANNEL
var zoom_at_af_point = ZOOM_AT_AF_POINT
var ev = EV
var gamma = GAMMA
onready var language = get_fixed_locale()

var select_color = Color(1, 1, 1)
var mark_color = Color(0.5, 1, 0.3)
var version = "v0.1.12"

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
  bps = BPS
  show_thumb_first = SHOW_THUMB_FIRST
  cache_round = CACHE_ROUND
  output_color = OUTPUT_COLOR
  rating_type = RATING_TYPE
  language = get_fixed_locale()
  renderer = RENDERER
  export_associated = EXPORT_ASSOCIATED
  shadow_thld = SHADOW_THLD
  highlight_thld = HIGHLIGHT_THLD
  highlight_one_channel = HIGHLIGHT_ONE_CHANNEL
  zoom_at_af_point = ZOOM_AT_AF_POINT
  ev = EV
  gamma = GAMMA
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
    "highlight_thld": highlight_thld,
    "highlight_one_channel": highlight_one_channel,
    "zoom_at_af_point": zoom_at_af_point,
    "ev": ev,
    "gamma": gamma
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
    
    bps = dict.get("bps", BPS)
    show_thumb_first = dict.get("show_thumb_first", SHOW_THUMB_FIRST)
    cache_round = dict.get("cache_round", CACHE_ROUND)
    output_color = dict.get("output_color", OUTPUT_COLOR)
    rating_type = dict.get("rating_type", RATING_TYPE)
    language = dict.get("language", get_fixed_locale())
    export_associated = dict.get("export_associated", EXPORT_ASSOCIATED)
    open_folder = dict.get("open_folder", "")
    export_folder = dict.get("export_folder", "")
    shadow_thld = dict.get("shadow_thld", SHADOW_THLD)
    highlight_thld = dict.get("highlight_thld", HIGHLIGHT_THLD)
    highlight_one_channel = dict.get("highlight_one_channel", HIGHLIGHT_ONE_CHANNEL)
    zoom_at_af_point = dict.get("zoom_at_af_point", ZOOM_AT_AF_POINT)
    ev = dict.get("ev", EV)
    gamma = dict.get("gamma", GAMMA)
    
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
  renderer = RENDERER
  var config = ConfigFile.new()
  var err = config.load("user://config.cfg")
  if err == OK:
    renderer = config.get_value("rendering", "quality/driver/driver_name", RENDERER)
  
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
    
