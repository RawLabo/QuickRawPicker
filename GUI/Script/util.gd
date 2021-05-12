extends Node

func logx(msg):
  var dt = OS.get_datetime()
  printraw("%02d:%02d " % [dt.minute,dt.second])
  if typeof(msg) == TYPE_ARRAY:
    for x in msg:
      printraw(str(x) + " ")
  else:
    printraw(str(msg))
    
  printraw("\n")
