extends Control

signal file_exported(photos)

enum DialogType { OpenDir, ExportByCopy }
var dialog_type = DialogType.OpenDir

func _ready():
  $Container/Fn.get_popup().connect("id_pressed", self, "_on_Fn_id_pressed")
  for key in Settings.OutputColors.keys():
    $SettingsDialog/Tabs/general/DisplayColorSpaceOption.add_item(key)
  for key in Settings.RatingType.keys():
    $SettingsDialog/Tabs/general/RatingTypeOption.add_item(key)
  
func _on_Reset_pressed():
  Util.log("_on_Reset_pressed")
  Settings.reset()
  update_settings_dialog()
  
func update_settings_dialog():
  $SettingsDialog/Tabs/general/BpsOption.select(0 if Settings.bps == 16 else 1)
  $SettingsDialog/Tabs/general/ShowThumbFirstOption.select(0 if Settings.show_thumb_first else 1)
  $SettingsDialog/Tabs/general/CacheRoundSpinBox.value = Settings.cache_round
  $SettingsDialog/Tabs/general/DisplayColorSpaceOption.select(int(Settings.output_color))
  $SettingsDialog/Tabs/general/RatingTypeOption.select(int(Settings.rating_type))
  $SettingsDialog/Tabs/general/LanguageOption.select(Settings.Language[Settings.language])
  $SettingsDialog/Tabs/general/ExportAssociatedLabelEdit.text = Settings.export_associated
  $SettingsDialog/Tabs/render/RendererOption.select(0 if Settings.renderer == "GLES3" else 1)
  $SettingsDialog/Tabs/render/ShadowThldBox.value = Settings.shadow_thld
  $SettingsDialog/Tabs/render/HighlightThldBox.value = Settings.highlight_thld
  
func popup_about_dialog():
  var about = AcceptDialog.new()
  about.name = "AboutDialog"
  about.get_child(1).align = HALIGN_CENTER
  about.dialog_text = "%s %s\nCopyright © 2021 qdwang.  All rights reserved.\nLicense: LGPL-2.1" % [Settings.project_name, Settings.version]
  about.window_title = "about"
  
  if has_node("AboutDialog"):
    remove_child($AboutDialog)
    
  add_child(about)
  about.popup_centered()
  
func gen_file_dialog():
  # workaround for FileDialog locale issue
  var dialog = FileDialog.new()
  dialog.mode_overrides_title = false
  dialog.resizable = true
  dialog.mode = FileDialog.MODE_OPEN_DIR
  dialog.access = FileDialog.ACCESS_FILESYSTEM
  dialog.name = "FDialog"
  
  if has_node("FDialog"):
    $FDialog.disconnect("dir_selected", self, "_on_Dialog_dir_selected")
    remove_child($FDialog)
  
  add_child(dialog)
  dialog.connect("dir_selected", self, "_on_Dialog_dir_selected")
  return dialog

func _on_Fn_id_pressed(id):
  if id == 100:
    # export selected
    dialog_type = DialogType.ExportByCopy
    var dialog = gen_file_dialog()
    dialog.window_title = "copy_marked_photos_to_folder"
    dialog.current_dir = Settings.export_folder
    dialog.popup_centered_clamped(Vector2(1200, 800), 0.9)
    
  elif id == 200:
    # settings
    update_settings_dialog()
    $SettingsDialog.popup_centered()
    
  elif id == 300:
    # about
    popup_about_dialog()
  
  elif id == 301:
    OS.shell_open(OS.get_user_data_dir())
  
  
func _on_OpenFolder_pressed():
  dialog_type = DialogType.OpenDir
  var dialog = gen_file_dialog()
  dialog.window_title = "open_folder_with_Raw_images"
  dialog.current_dir = Settings.open_folder
  dialog.popup_centered_clamped(Vector2(1200, 800), 0.9)

func _on_Dialog_dir_selected(dir):
  if dialog_type == DialogType.OpenDir:
    Settings.open_folder = dir
    Util.Nodes["PhotoList"].show_folder_images(dir)
  elif dialog_type == DialogType.ExportByCopy:
    Settings.export_folder = dir
    var photos = Util.Nodes["PhotoList"].get_marked_photos()
    var export_patterns = Settings.export_associated.split("/", false)
    Threading.pending_jobs.append(["export_files", photos, self, [dir, export_patterns, $ExportProgress/ProgressBar]])
    $ExportProgress.popup_centered()

  Settings.save_settings()

func _on_Operations_file_exported(_photos):
  $ExportProgress.visible = false

func _on_BpsOption_item_selected(index):
  Settings.bps = 16 if index == 0 else 8
  Settings.save_settings()
  Settings.update_title()

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
  
func _on_OpenLogFolder_pressed():
  OS.shell_open(OS.get_user_data_dir())

func _on_LanguageOption_item_selected(index):
  Settings.language = Settings.Language.keys()[index]
  Settings.save_settings()
  Settings.update_title()

func _on_RendererOption_item_selected(index):
  Settings.renderer = $SettingsDialog/Tabs/render/RendererOption.get_item_text(index)
  Settings.save_settings()
  
func _on_ExportAssociatedLabelEdit_text_changed(new_text):
  Settings.export_associated = new_text
  Settings.save_settings()

func _on_ShadowThldBox_value_changed(value):
  Settings.shadow_thld = value
  Settings.save_settings()

func _on_HighlightThldBox_value_changed(value):
  Settings.highlight_thld = value
  Settings.save_settings()

func _on_ShadowThldBox_focus_exited():
  $SettingsDialog/Tabs/render/ShadowThldBox.value = Settings.shadow_thld

func _on_HighlightThldBox_focus_exited():
  $SettingsDialog/Tabs/render/HighlightThldBox.value = Settings.highlight_thld
