extends TabContainer

var title = tr("MENU_OPTIONS")

func _ready() -> void:
	size = get_parent_area_size()
	for lang in GlobalSettings.LANGUAGE:
		%LangOption.add_item(lang)
	%LangOption.select(GlobalSettings.language)
	%LandscapeOption.button_pressed = GlobalSettings.landscape



func _on_landscape_option_toggled(toggled_on: bool) -> void:
	GlobalSettings.set_landscape(toggled_on)

func _on_lang_option_item_selected(index: int) -> void:
	GlobalSettings.set_language(index)
