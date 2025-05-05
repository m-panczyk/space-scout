extends Node

var config = ConfigFile.new()
var config_path = "user://config.cfg"
var virtual_resolution:Vector2 = Vector2(1080,1920)
var scale_factor
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
func _enter_tree() -> void:
	adjust_viewport_scale()
func _ready() -> void:
	print("loading settings")
	if config.load(config_path) == OK:
		set_language(config.get_value('game_settings','language',0))
		set_landscape(config.get_value('video_settings','landscape',0))

func set_landscape(landscape_value:bool) -> void:
	landscape = landscape_value
	ProjectSettings.set_setting("display/window/handheld/orientation",int(landscape))
	DisplayServer.screen_set_orientation(LANDSCAPE[int(landscape_value)])
	
func set_language(lang_id:int) -> void:
	language = lang_id
	TranslationServer.set_locale(LANGUAGE[language])

func save() ->void:
	config.set_value('game_settings','language',language)
	config.set_value('video_settings','landscape',landscape)
	print(config.to_string())
	config.save("user://config.cfg")

func adjust_viewport_scale() -> void:
	# Get the screen DPI (dots per inch)
	var screen_dpi = DisplayServer.screen_get_dpi()
	
	# Get the default reference DPI (96 is common for desktop monitors)
	var reference_dpi = 96.0
	
	# Calculate scale factor based on the ratio of actual DPI to reference DPI
	scale_factor = screen_dpi / reference_dpi
	
	# Optional: Apply clamping to avoid extreme scaling
	scale_factor = clamp(scale_factor, 0.5, 3.0)
	
	# Log the detected values
	print("Screen DPI: ", screen_dpi)
	print("Applied scale factor: ", scale_factor)
	
	get_tree().root.content_scale_factor = scale_factor
	# Get the viewport
	#var viewport = get_viewport()
	
	# Apply the scale to the viewport's canvas transform
	#var transform = Transform2D().scaled(Vector2(scale_factor, scale_factor))
	#viewport.set_canvas_transform(transform)
	
	# If using Godot 4.x, you might also want to adjust the window size
	# to maintain the same physical size on screen
	#var window_size = DisplayServer.window_get_size()
	#var scaled_size = Vector2i(window_size.x / scale_factor, window_size.y / scale_factor)
	#DisplayServer.window_set_size(scaled_size)	
