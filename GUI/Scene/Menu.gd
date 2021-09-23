extends VBoxContainer

signal file_exported(photos)

const file_dialog_size = Vector2(1200, 800)

enum DialogType { OpenDir, ExportByCopy }
var dialog_type = DialogType.OpenDir

func _ready():
  pass
  
func is_settings_dialog_open():
  return $SettingsBtn/SettingsDialog.visible
  
func is_file_dialog_open():
  return has_node("FDialog") and $FDialog.visible
  
func _on_SettingsBtn_pressed():
  $SettingsBtn/SettingsDialog.show()

func _on_Compare_pressed():
  Util.Nodes["PhotoList"]._on_Compare_pressed()

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
