extends Node

var config = ConfigFile.new()
var config_path = "user://config.cfg"
var virtual_resolution:Vector2 = Vector2(1080,1920)
var scale_factor
var user_dpi_scale:float = 1.0
var language = 0
var landscape:bool = false
const LANDSCAPE =[DisplayServer.ScreenOrientation.SCREEN_PORTRAIT,DisplayServer.ScreenOrientation.SCREEN_LANDSCAPE]
const LANGUAGE = ['pl','en','fr','es','de','it','pt_br','pt_pt','ru','el','tr','da','nb','sv','nl','fi','ja','zh_cn','zh_tw','ko','cs','hu','ro','th','bg','he','ar','bs']
const LANGUAGE_EMOJI = [
  '🇵🇱',#pl
  '🇬🇧',#en
  '🇫🇷',#fr
  '🇪🇸',#es
  '🇩🇪',#de
  '🇮🇹',#it
  '🇧🇷',#pt_br
  '🇵🇹',#pt_pt
  '🇷🇺',#ru
  '🇬🇷',#el
  '🇹🇷',#tr
  '🇩🇰',#da
  '🇳🇴',#nb
  '🇸🇪',#sv
  '🇳🇱',#nl
  '🇫🇮',#fi
  '🇯🇵',#ja
  '🇨🇳',#zh_cn
  '🇹🇼',#zh_tw
  '🇰🇷',#ko
  '🇨🇿',#cs
  '🇭🇺',#hu
  '🇷🇴',#ro
  '🇹🇭',#th
  '🇧🇬',#bg
  '🇮🇱',#he
  '🇸🇦',#ar
  '🇧🇦' #bs
];
var virtual_navigation: bool = false
var gesture_navigation: bool = false
enum TouchControlType {
	JOYPAD_TOUCH,
	POINT
}

var touch_controls = TouchControlType.POINT

func _enter_tree() -> void:
	adjust_viewport_scale()
	
func _ready() -> void:
	load_settings()

func set_landscape(landscape_value:bool) -> void:
	landscape = landscape_value
	ProjectSettings.set_setting("display/window/handheld/orientation", int(landscape))
	DisplayServer.screen_set_orientation(LANDSCAPE[int(landscape_value)])
	
func set_language(lang_id:int) -> void:
	language = lang_id
	TranslationServer.set_locale(LANGUAGE[language])

func set_touch_controls(control_type:TouchControlType) -> void:
	touch_controls = control_type

func set_user_dpi_scale(scale:float) -> void:
	user_dpi_scale = clamp(scale, 0.5, 2.0)
	adjust_viewport_scale()

# Add these setter functions with your other setters
func set_virtual_navigation(enabled: bool) -> void:
	virtual_navigation = enabled
	var navigation = get_node_or_null("../Game/Navigation")
	if navigation :
		navigation.visible = virtual_navigation

func set_gesture_navigation(enabled: bool) -> void:
	gesture_navigation = enabled


func load_settings() -> void:
	print_debug("loading settings")
	if config.load(config_path) == OK:
		set_language(config.get_value('game_settings', 'language', 0))
		set_landscape(config.get_value('video_settings', 'landscape', false))
		set_touch_controls(config.get_value('control_settings', 'touch_type', TouchControlType.JOYPAD_TOUCH))
		set_user_dpi_scale(config.get_value('video_settings', 'user_dpi_scale', 1.0))
		set_virtual_navigation(config.get_value('control_settings', 'virtual_navigation', false))
		set_gesture_navigation(config.get_value('control_settings', 'gesture_navigation', false))
	
func save_settings() -> void:
	config.set_value('game_settings', 'language', language)
	config.set_value('video_settings', 'landscape', landscape)
	config.set_value('control_settings', 'touch_type', touch_controls)
	config.set_value('video_settings', 'user_dpi_scale', user_dpi_scale)
	config.set_value('control_settings', 'virtual_navigation', virtual_navigation)
	config.set_value('control_settings', 'gesture_navigation', gesture_navigation)
	
	print_debug(config.to_string())
	config.save("user://config.cfg")

func adjust_viewport_scale() -> void:
	var screen_dpi = DisplayServer.screen_get_dpi()
	var reference_dpi = 96.0
	scale_factor = (screen_dpi / reference_dpi) * user_dpi_scale
	scale_factor = clamp(scale_factor, 0.5, 3.0)
	
	print("Screen DPI: ", screen_dpi)
	print("User DPI scale: ", user_dpi_scale)
	print("Applied scale factor: ", scale_factor)
	
	get_tree().root.content_scale_factor = scale_factor
