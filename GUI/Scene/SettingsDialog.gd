extends WindowDialog

func _ready():
  for key in Settings.OutputColors.keys():
    $Tabs/render/DisplayColorSpaceOption.add_item(key)
  for key in Settings.RatingType.keys():
    $Tabs/general/RatingTypeOption.add_item(key)
  for key in Settings.SortMethod.keys():
    $Tabs/general/SortMethodOption.add_item(key)

func show():
  rect_scale = Vector2(Settings.ui_scale, Settings.ui_scale)
  update_settings_dialog()
  popup_centered()
  
func update_settings_dialog():
  $Tabs/general/BpsOption.select(0 if Settings.bps == 16 else 1)
  $Tabs/general/ShowThumbFirstOption.select(0 if Settings.show_thumb_first else 1)
  $Tabs/general/ZoomAtAFPointOption.select(0 if Settings.zoom_at_af_point else 1)
  $Tabs/general/CacheRoundSpinBox.value = Settings.cache_round
  $Tabs/general/UIScaleSpinBox.value = Settings.ui_scale
  $Tabs/render/DisplayColorSpaceOption.select(int(Settings.output_color))
  $Tabs/general/RatingTypeOption.select(int(Settings.rating_type))
  $Tabs/general/SortMethodOption.select(int(Settings.sort_method))
  $Tabs/general/LanguageOption.select(Settings.Language[Settings.language])
  $Tabs/general/ExportAssociatedLabelEdit.text = Settings.export_associated
  $Tabs/render/RendererOption.select(0 if Settings.renderer == "GLES3" else 1)
  $Tabs/render/ShadowThldBox.value = Settings.shadow_thld
  $Tabs/render/HighlightBox/HighlightThldBox.value = Settings.highlight_thld
  $Tabs/render/HighlightBox/OneChannel.pressed = Settings.highlight_one_channel
  $Tabs/render/DefaultEVBox.value = Settings.ev
  $Tabs/render/DefaultGammaBox.value = Settings.gamma
  
func _on_Reset_pressed():
  Settings.reset()
  update_settings_dialog()

func _on_BpsOption_item_selected(index):
  Settings.bps = 16 if index == 0 else 8
  Settings.save_settings()
  Settings.update_title()

func _on_ShowThumbFirstOption_item_selected(index):
  Settings.show_thumb_first = index == 0
  Settings.save_settings()
  
func _on_ZoomAtAFPointOption_item_selected(index):
  Settings.zoom_at_af_point = index == 0
  Settings.save_settings()
  
func _on_CacheRoundSpinBox_value_changed(value):
  Settings.cache_round = value
  Settings.save_settings()

func _on_DisplayColorSpaceOption_item_selected(index):
  Settings.output_color = index
  Settings.save_settings()
  Settings.update_title()

func _on_SortMethodOption_item_selected(index):
  Settings.sort_method = index
  Settings.save_settings()
  
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
  Settings.renderer = $Tabs/render/RendererOption.get_item_text(index)
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

func _on_OneChannel_toggled(button_pressed):
  Settings.highlight_one_channel = button_pressed
  Settings.save_settings()

func _on_DefaultEVBox_value_changed(value):
  Settings.ev = value
  Settings.save_settings()

func _on_DefaultGammaBox_value_changed(value):
  Settings.gamma = value
  Settings.save_settings()

func _on_HelpBtn_pressed():
  OS.shell_open("https://github.com/qdwang/QuickRawPicker/blob/main/Doc/Settings.md")

func _on_UIScaleSpinBox_value_changed(value):
  Settings.ui_scale = value
  Settings.save_settings()
