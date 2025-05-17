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
	# Signal or additional setup for touch controls can be added here if needed
	
func set_user_dpi_scale(scale:float) -> void:
	user_dpi_scale = clamp(scale, 0.5, 2.0)  # Reasonable limits for user scaling
	adjust_viewport_scale()  # Apply the new scale
func load_settings() -> void:
	print_debug("loading settings")
	if config.load(config_path) == OK:
		set_language(config.get_value('game_settings', 'language', 0))
		set_landscape(config.get_value('video_settings', 'landscape', false))
		set_touch_controls(config.get_value('control_settings', 'touch_type', TouchControlType.JOYPAD_TOUCH))
		set_user_dpi_scale(config.get_value('video_settings', 'user_dpi_scale', 1.0))
	
func save_settings() -> void:
	config.set_value('game_settings', 'language', language)
	config.set_value('video_settings', 'landscape', landscape)
	config.set_value('control_settings', 'touch_type', touch_controls)
	config.set_value('video_settings', 'user_dpi_scale', user_dpi_scale)
	print_debug(config.to_string())
	config.save("user://config.cfg")

func adjust_viewport_scale() -> void:
	# Get the screen DPI (dots per inch)
	var screen_dpi = DisplayServer.screen_get_dpi()
	
	# Get the default reference DPI (96 is common for desktop monitors)
	var reference_dpi = 96.0
	
	# Calculate scale factor based on the ratio of actual DPI to reference DPI
	scale_factor = (screen_dpi / reference_dpi) * user_dpi_scale
	
	# Optional: Apply clamping to avoid extreme scaling
	scale_factor = clamp(scale_factor, 0.5, 3.0)
	
	# Log the detected values
	print("Screen DPI: ", screen_dpi)
	print("User DPI scale: ", user_dpi_scale)
	print("Applied scale factor: ", scale_factor)
	
	get_tree().root.content_scale_factor = scale_factor

var questions = [
	['Question','GOOD','BAD','BAD'],
	['1+1=?','2','1','11']
	]

var current_question_index: int = 0
var current_correct_answer_index: int = 0
var shuffled_answers: Array = []

func get_question() -> String:
	# Select a random question
	current_question_index = randi() % questions.size()
	var question_data = questions[current_question_index]
	
	# Get the question text (first element)
	var question_text = question_data[0]
	
	# Get all answers and shuffle them
	shuffled_answers = []
	for i in range(1, question_data.size()):
		shuffled_answers.append(question_data[i])
	
	# Remember which answer is correct (index 0 is always correct in original array)
	var correct_answer = question_data[1]
	
	# Shuffle the answers array
	shuffled_answers.shuffle()
	
	# Find where the correct answer ended up after shuffling
	current_correct_answer_index = shuffled_answers.find(correct_answer)
	
	return question_text

func get_answers() -> Array:
	return shuffled_answers

func is_correct_answer(selected_index: int) -> bool:
	return selected_index == current_correct_answer_index
