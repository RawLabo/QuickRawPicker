extends VBoxContainer

signal file_exported(photos)

const file_dialog_size = Vector2(1200, 800)

enum DialogType { OpenDir, ExportByCopy }
var dialog_type = DialogType.OpenDir

func _ready():
  $HelpBtn.get_popup().connect("id_pressed", self, "_on_HelpBtn_id_pressed")
  $PinBtn.pressed = Settings.pin_menu
  
func _on_HelpBtn_id_pressed(id):
  match id:
    1:
      popup_about_dialog()
    2:
      OS.shell_open("%s%s" % ["file://" if Util.is_macos else "", OS.get_user_data_dir()])
    3:
      OS.shell_open("https://github.com/qdwang/QuickRawPicker/blob/main/Doc/Shortcuts.md")
      
func is_settings_dialog_open():
  return $SettingsBtn/SettingsDialog.visible

func is_file_dialog_open():
  return has_node("FDialog") and $FDialog.visible
  
func _on_SettingsBtn_pressed():
  $SettingsBtn/SettingsDialog.show()

func _on_Compare_pressed():
  Util.Nodes["PhotoList"]._on_Compare_pressed()
  
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
  
func _on_OpenFolderBtn_pressed():
  dialog_type = DialogType.OpenDir
  var dialog = gen_file_dialog()
  dialog.window_title = "open_folder_with_Raw_images"
  dialog.current_dir = Settings.open_folder
  dialog.popup_centered_clamped(file_dialog_size, 0.9)

func _on_ExportBtn_pressed():
  dialog_type = DialogType.ExportByCopy
  var dialog = gen_file_dialog()
  dialog.window_title = "copy_marked_photos_to_folder"
  dialog.current_dir = Settings.export_folder
  dialog.popup_centered_clamped(file_dialog_size, 0.9)

func _on_Dialog_dir_selected(dir):
  if dialog_type == DialogType.OpenDir:
    Settings.open_folder = dir
    Util.Nodes["PhotoList"].show_folder_images(dir)
    $SubMenu.visible = true
    
  elif dialog_type == DialogType.ExportByCopy:
    Settings.export_folder = dir
    var photos = Util.Nodes["PhotoList"].get_marked_photos()
    var export_patterns = Settings.export_associated.split("/", false)
    Threading.pending_jobs.append(["export_files", photos, self, [dir, export_patterns]])

  Settings.save_settings()

func fullscreen_btn_press():
  $FullscreenBtn.pressed = not $FullscreenBtn.pressed
  _on_FullscreenBtn_toggled($FullscreenBtn.pressed)
  
func _on_FullscreenBtn_toggled(button_pressed):
  if button_pressed:
    $FullscreenBtn.text = ""
    OS.window_fullscreen = true
  else:
    $FullscreenBtn.text = ""
    OS.window_fullscreen = false

func _on_PinBtn_toggled(button_pressed):
  Settings.pin_menu = button_pressed
  Settings.save_settings()
  Util.Nodes["Main"].set_grid_left_margin(button_pressed)
