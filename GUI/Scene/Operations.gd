extends Control

enum DialogType { OpenDir, ExportByMove, ExportByCopy }

var dialog_type = DialogType.OpenDir

func _on_OpenFolder_pressed():
  dialog_type = DialogType.OpenDir
  $Dialog.window_title = "Open Folder with Raw images"
  $Dialog.popup_centered_clamped(Vector2(1200, 800), 0.9)

func _on_Dialog_dir_selected(dir):
  get_parent().emit_signal("open_folder_selected", dir)
