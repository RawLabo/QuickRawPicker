extends Node

const auto_bright = false

var bps = 16
var show_thumb_first = true
var cache_round = 2
var output_color = OutputColors.SRGB
var rating_type = RatingType.XMP
var open_folder = ""
var export_folder = ""

var select_color = Color(1, 1, 1)
var mark_color = Color(0.5, 1, 0.3)
var version = "v0.1.6"

onready var project_name = ProjectSettings.get_setting("application/config/name")

var extension_filter = [
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
  OS.set_window_title("%s %s / bit:%s / colorspace:%s" % [project_name, version, bps, OutputColors.keys()[output_color]])
  
func reset():
  bps = 16
  show_thumb_first = true
  cache_round = 2
  output_color = OutputColors.SRGB
  rating_type = RatingType.XMP
  save_settings()
  
func save_settings():
  var file = File.new()
  var content = JSON.print({
    "bps": bps,
    "show_thumb_first": show_thumb_first,
    "cache_round": cache_round,
    "output_color": output_color,
    "rating_type": rating_type,
    "open_folder": open_folder,
    "export_folder": export_folder
  })
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
    open_folder = dict.get("open_folder", "")
    export_folder = dict.get("export_folder", "")
    
  file.close()
