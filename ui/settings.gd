extends Control

var title = tr("MENU_OPTIONS")

func _ready() -> void:
	for lang in GlobalSettings.LANGUAGE:
		%LangOption.add_item(lang)
	%LangOption.select(GlobalSettings.language)
	%LandscapeOption.toggle_mode = GlobalSettings.landscape
