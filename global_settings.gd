extends Node

var config = ConfigFile.new()
var virtual_resolution:Vector2 = Vector2(1080,1920)
var language = 0
var landscape:bool = false
const LANGUAGE = ['pl','en']

func _ready() -> void:
	print("loading global settings")
	if config.load("user://config.cfg"):
		set_language(config.get_value('game_settings','language',0))
		set_landscape(config.get_value('video_settings','landscape',0))

func set_landscape(landscape_value:bool) -> void:
	landscape = landscape_value
	ProjectSettings.set_setting("display/window/handheld/orientation",int(landscape))
	
func set_language(lang_id:int) -> void:
	language = lang_id
	TranslationServer.set_locale(LANGUAGE[language])
	
