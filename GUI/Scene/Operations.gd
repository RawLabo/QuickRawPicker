extends Control

enum DialogType { OpenDir, ExportByCopy }
var dialog_type = DialogType.OpenDir

func _ready():
  $Container/Fn.get_popup().connect("id_pressed", self, "_on_Fn_id_pressed")
  for key in Settings.OutputColors.keys():
    $SettingsDialog/Grid/DisplayColorSpaceOption.add_item(key)
  for key in Settings.RatingType.keys():
    $SettingsDialog/Grid/RatingTypeOption.add_item(key)
  
func _on_Reset_pressed():
  Settings.reset()
  update_settings_dialog()
  
func update_settings_dialog():
  $SettingsDialog/Grid/BpsOption.select(0 if Settings.bps == 16 else 1)
  $SettingsDialog/Grid/AutoBrightOption.select(0 if Settings.auto_bright else 1)
  $SettingsDialog/Grid/ShowThumbFirstOption.select(0 if Settings.show_thumb_first else 1)
  $SettingsDialog/Grid/CacheRoundSpinBox.value = Settings.cache_round
  $SettingsDialog/Grid/DisplayColorSpaceOption.select(int(Settings.output_color))
  $SettingsDialog/Grid/RatingTypeOption.select(int(Settings.rating_type))
  
func _on_Fn_id_pressed(id):
  if id == 0:
    # export selected
    dialog_type = DialogType.ExportByCopy
    $Dialog.window_title = "Copy selected photos to folder"
    $Dialog.popup_centered_clamped(Vector2(1200, 800), 0.9)
  elif id == 1:
    # settings
    update_settings_dialog()
    $SettingsDialog.popup_centered()
  elif id == 2:
    # about
    pass
  
func _on_OpenFolder_pressed():
  dialog_type = DialogType.OpenDir
  $Dialog.window_title = "Open folder with RAW images"
  $Dialog.popup_centered_clamped(Vector2(1200, 800), 0.9)

func _on_Dialog_dir_selected(dir):
  if dialog_type == DialogType.OpenDir:
    get_parent().emit_signal("open_folder_selected", dir)
  elif dialog_type == DialogType.ExportByCopy:
    pass

func _on_BpsOption_item_selected(index):
  Settings.bps = 16 if index == 0 else 8
  Settings.save_settings()
  Settings.update_title()

func _on_AutoBrightOption_item_selected(index):
  Settings.auto_bright = index == 0
  Settings.save_settings()

func _on_ShowThumbFirstOption_item_selected(index):
  Settings.show_thumb_first = index == 0
  Settings.save_settings()
  
func _on_CacheRoundSpinBox_value_changed(value):
  Settings.cache_round = value
  Settings.save_settings()

func _on_DisplayColorSpaceOption_item_selected(index):
  Settings.output_color = index
  Settings.save_settings()
  Settings.update_title()

func _on_RatingTypeOption_item_selected(index):
  Settings.rating_type = index
  Settings.save_settings()
  
