extends Node

onready var Bridge = preload("res://Asset/Lib/main_nativescript.gdns").new()
onready var log_time = OS.get_ticks_msec()

var log_thd = 3
enum LogLevel {Error, Critical, Info, Verbose}
func log(msg, mark = "", level = LogLevel.Info):
  var data = ""
  if typeof(msg) == TYPE_ARRAY:
    for x in msg:
      data += str(x) + " "
  else:
    data = str(msg)
  
  if level <= log_thd:
    var now = OS.get_ticks_msec()
    print("%s[%s][%d]: %s" % [LogLevel.keys()[level], mark, now - log_time, data])
    log_time = now
