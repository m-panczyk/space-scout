extends Control

var title = tr("MENU_OPTIONS")

func _ready() -> void:
	
	size = get_parent_area_size()
	for lang in GlobalSettings.LANGUAGE_EMOJI:
		%LangOption.add_item(lang)
	%LangOption.select(GlobalSettings.language)
	%LandscapeOption.button_pressed = GlobalSettings.landscape
	%TouchOption.select(GlobalSettings.touch_controls)
	%DPIScale.value = GlobalSettings.user_dpi_scale
	%DPIScale.visible = !(%DPIScale.value == 1.0)
	%DPIAuto.button_pressed = %DPIScale.value == 1.0
	

func _on_landscape_option_toggled(toggled_on: bool) -> void:
	GlobalSettings.set_landscape(toggled_on)
	$SaveSettings.disabled = false

func _on_lang_option_item_selected(index: int) -> void:
	GlobalSettings.set_language(index)
	$SaveSettings.disabled = false

func _on_touch_option_item_selected(index: int) -> void:
	GlobalSettings.set_touch_controls(index)
	$SaveSettings.disabled = false

func _on_dpi_auto_toggled(toggled_on: bool) -> void:
	%DPIScale.visible = !toggled_on
	if toggled_on:
		%DPIScale.value = 1.0




func _on_dpi_scale_value_changed(value: float) -> void:
	print_debug("dpi change: ",value)
	GlobalSettings.set_user_dpi_scale(value)
	$SaveSettings.disabled = false


func _on_save_settings_pressed() -> void:
	GlobalSettings.save_settings()
	$SaveSettings.disabled = true


func _on_tree_exited() -> void:
	GlobalSettings.load_settings()
