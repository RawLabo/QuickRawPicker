extends Node

var bps = 16
var auto_bright = false
var show_thumb_first = true
var cache_round = 2
var select_color = Color(1, 1, 1)
var mark_color = Color(0, 1, 0, 0.7)
var output_color = OutputColors.SRGB

var extension_filter = [
  "ARW",
  "RW2",
  "ORF",
  "CR3",
  "DNG",
  "dng"
]

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
  update_title()
  
func update_title():
  OS.set_window_title("%s / bit:%s / colorspace:%s" % ["QuickRawPicker", bps, OutputColors.keys()[output_color]])
  
