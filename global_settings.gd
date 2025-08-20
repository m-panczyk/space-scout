extends Node

var config = ConfigFile.new()
var config_path = "user://config.cfg"
var virtual_resolution:Vector2 = Vector2(1080,1920)
var scale_factor
var user_dpi_scale:float = 1.0
var language = 0
var landscape:bool = false
var tutorial_done:bool = false
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
	add_touch_control()
func add_touch_control() -> void:
	var game = get_tree().current_scene
	if touch_controls == TouchControlType.JOYPAD_TOUCH and game != null:
		if game.get_child(0).is_class("TouchScreenJoystick"):
			var gamepad = load("res://ui/TouchScreenJoystick.tscn")
			gamepad = gamepad.instantiate()
			game.add_child(gamepad)
			game.move_child(gamepad, 0)
	elif game != null:
		var gamepad = game.get_child(0)
		if gamepad.is_class("TouchScreenJoystick"):
			gamepad.queue_free()
func set_user_dpi_scale(scale:float) -> void:
	user_dpi_scale = clamp(scale, 0.5, 2.0)
	adjust_viewport_scale()

func set_tutorial_done(completed:bool) -> void:
	tutorial_done = completed

# Add these setter functions with your other setters
func set_virtual_navigation(enabled: bool) -> void:
	virtual_navigation = enabled
	var navigation = get_node_or_null("../Game/Navigation")
	if navigation :
		navigation.visible = virtual_navigation

func set_gesture_navigation(enabled: bool) -> void:
	gesture_navigation = enabled

func reset_to_defaults() -> void:
	print_debug("Resetowanie ustawień do wartości domyślnych")
	
	# Usuń istniejący plik konfiguracyjny
	if FileAccess.file_exists(config_path):
		DirAccess.remove_absolute(config_path)
		print_debug("Plik konfiguracyjny został usunięty")
	
	# Ustaw domyślne wartości
	set_language(0)  # polski jako domyślny
	set_landscape(false)  # portret jako domyślny
	set_touch_controls(TouchControlType.JOYPAD_TOUCH)  # domyślny typ kontrolek
	set_user_dpi_scale(1.0)  # domyślna skala DPI
	set_virtual_navigation(false)  # wyłączona wirtualna nawigacja
	set_gesture_navigation(false)  # wyłączona nawigacja gestów
	set_tutorial_done(false)  # tutorial nie ukończony
	
	print_debug("Ustawienia zostały zresetowane do wartości domyślnych")

func load_settings() -> void:
	print_debug("loading settings")
	if config.load(config_path) == OK:
		set_language(config.get_value('game_settings', 'language', 0))
		set_landscape(config.get_value('video_settings', 'landscape', false))
		set_touch_controls(config.get_value('control_settings', 'touch_type', TouchControlType.JOYPAD_TOUCH))
		set_user_dpi_scale(config.get_value('video_settings', 'user_dpi_scale', 1.0))
		set_virtual_navigation(config.get_value('control_settings', 'virtual_navigation', false))
		set_gesture_navigation(config.get_value('control_settings', 'gesture_navigation', false))
		set_tutorial_done(config.get_value('game_settings', 'tutorial_done', false))
	
func save_settings() -> void:
	config.set_value('game_settings', 'language', language)
	config.set_value('video_settings', 'landscape', landscape)
	config.set_value('control_settings', 'touch_type', touch_controls)
	config.set_value('video_settings', 'user_dpi_scale', user_dpi_scale)
	config.set_value('control_settings', 'virtual_navigation', virtual_navigation)
	config.set_value('control_settings', 'gesture_navigation', gesture_navigation)
	config.set_value('game_settings', 'tutorial_done', tutorial_done)
	
	print_debug(config.to_string())
	config.save("user://config.cfg")

func adjust_viewport_scale() -> void:
	var screen_dpi = DisplayServer.screen_get_dpi()
	var reference_dpi = 96.0
	#var reference_dpi = 160.0
	# Calculate initial scale factor
	var linear_scale = (screen_dpi / reference_dpi) * user_dpi_scale
	
	# Apply logarithmic scaling
	scale_factor = apply_logarithmic_scale(linear_scale)
	
	print("Screen DPI: ", screen_dpi)
	print("User DPI scale: ", user_dpi_scale)
	print("Applied scale factor: ", scale_factor)
	
	call_deferred("_apply_scale_factor")

func apply_logarithmic_scale(linear_value: float) -> float:
	var base_scale = 1.0
	
	if linear_value <= base_scale:
		return linear_value  # Don't modify scales at or below 1.0
	
	# For scales above 1.0, apply logarithmic compression
	var excess = linear_value - base_scale
	var log_excess = log(excess + 1) / log(3)  # Adjust divisor to change compression
	
	return base_scale + log_excess

func _apply_scale_factor():
	if get_tree() and get_tree().root:
		get_tree().root.content_scale_factor = scale_factor
