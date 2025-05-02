extends Control

var title = "SETTINGS"

func _ready() -> void:
	for lang in GlobalSettings.LANGUAGE:
		%LangOption.add_item(lang)
	%LangOption.select(GlobalSettings.language)
	%LandscapeOption.toggle_mode = GlobalSettings.landscape
