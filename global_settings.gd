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

# Nowe zmienne dla systemu pytań
var current_subject = QGen.Przedmiot.MATEMATYKA  # Domyślnie matematyka
var available_subjects = []

func _enter_tree() -> void:
	adjust_viewport_scale()
	
func _ready() -> void:
	load_settings()
	initialize_subjects()

func initialize_subjects():
	available_subjects = QGen.get_available_subjects()

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

# Nowa funkcja do ustawiania przedmiotu
func set_current_subject(subject: QGen.Przedmiot) -> void:
	current_subject = subject
	print("Zmieniono przedmiot na: ", QGen.get_subject_name(subject))

# Funkcja pobierająca dostępne przedmioty
func get_available_subjects() -> Array:
	return available_subjects

# Funkcja pobierająca nazwę aktualnego przedmiotu
func get_current_subject_name() -> String:
	return QGen.get_subject_name(current_subject)

# Funkcja pobierająca dostępne kategorie dla aktualnego przedmiotu i poziomu
func get_available_categories_for_current_subject(difficulty: int) -> Array:
	return QGen.get_available_categories(current_subject, difficulty)

# Funkcja pobierająca informacje o liczbie pytań w kategorii
func get_subject_statistics() -> Dictionary:
	var stats = {}
	
	for subject in available_subjects:
		var subject_name = QGen.get_subject_name(subject)
		stats[subject_name] = {}
		
		for difficulty in range(3):  # 0, 1, 2
			var difficulty_name = SaveData.get_difficulty_name_from_level(difficulty)
			var categories = QGen.get_available_categories(subject, difficulty)
			var total_questions = 0
			
			stats[subject_name][difficulty_name] = {
				"categories": [],
				"total_questions": 0
			}
			
			for category in categories:
				var category_name = QGen.get_category_name(category)
				var question_count = QGen.get_questions_count_in_category(category)
				total_questions += question_count
				
				stats[subject_name][difficulty_name]["categories"].append({
					"name": category_name,
					"questions": question_count
				})
			
			stats[subject_name][difficulty_name]["total_questions"] = total_questions
	
	return stats

func load_settings() -> void:
	print_debug("loading settings")
	if config.load(config_path) == OK:
		set_language(config.get_value('game_settings', 'language', 0))
		set_landscape(config.get_value('video_settings', 'landscape', false))
		set_touch_controls(config.get_value('control_settings', 'touch_type', TouchControlType.JOYPAD_TOUCH))
		set_user_dpi_scale(config.get_value('video_settings', 'user_dpi_scale', 1.0))
		
		# Wczytaj zapisany przedmiot
		var saved_subject = config.get_value('game_settings', 'current_subject', QGen.Przedmiot.MATEMATYKA)
		set_current_subject(saved_subject)
	
func save_settings() -> void:
	config.set_value('game_settings', 'language', language)
	config.set_value('video_settings', 'landscape', landscape)
	config.set_value('control_settings', 'touch_type', touch_controls)
	config.set_value('video_settings', 'user_dpi_scale', user_dpi_scale)
	config.set_value('game_settings', 'current_subject', current_subject)
	
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

# Zachowanie kompatybilności - stare pytania matematyczne
var questions = [
	['Question','GOOD','BAD','BAD'],
	['1+1=?','2','1','11']
]

var current_question_index: int = 0
var current_correct_answer_index: int = 0
var shuffled_answers: Array = []

# Zaktualizowana funkcja get_question z obsługą różnych przedmiotów
func get_question() -> String:
	var question_data
	
	# Generuj pytanie z aktualnie wybranego przedmiotu
	if current_subject == QGen.Przedmiot.MATEMATYKA:
		# Dla matematyki używamy starego systemu (dla kompatybilności)
		question_data = QGen.generate_question(SaveData.difficulty_level)
	else:
		# Dla innych przedmiotów używamy nowego systemu
		question_data = QGen.generate_question_from_subject(SaveData.difficulty_level, current_subject)
	
	# Jeśli nie udało się wygenerować pytania z wybranego przedmiotu, użyj matematyki
	if question_data == null or question_data.size() < 4:
		print("Błąd generowania pytania dla przedmiotu: ", QGen.get_subject_name(current_subject))
		question_data = QGen.generate_question(SaveData.difficulty_level)
	
	# Pobierz tekst pytania (pierwszy element)
	var question_text = question_data[0]
	
	# Pobierz wszystkie odpowiedzi i je pomieszaj
	shuffled_answers = []
	for i in range(1, question_data.size()):
		shuffled_answers.append(question_data[i])
	
	# Zapamiętaj poprawną odpowiedź (indeks 0 to zawsze poprawna w oryginalnej tablicy)
	var correct_answer = question_data[1]
	
	# Pomieszaj tablicę odpowiedzi
	shuffled_answers.shuffle()
	
	# Znajdź gdzie trafiła poprawna odpowiedź po pomieszaniu
	current_correct_answer_index = shuffled_answers.find(correct_answer)
	
	return question_text

# Funkcja do uzyskania pytania z określonej kategorii (nowa funkcjonalność)
func get_question_from_category(difficulty: int, category: QGen.Kategoria) -> String:
	var question_data = QGen.pobierz_pytanie_z_kategorii(difficulty, category)
	
	if question_data == null or question_data.size() < 4:
		print("Błąd generowania pytania z kategorii: ", QGen.get_category_name(category))
		# Fallback do losowego pytania matematycznego
		question_data = QGen.generate_question(difficulty)
	
	var question_text = question_data[0]
	
	shuffled_answers = []
	for i in range(1, question_data.size()):
		shuffled_answers.append(question_data[i])
	
	var correct_answer = question_data[1]
	shuffled_answers.shuffle()
	current_correct_answer_index = shuffled_answers.find(correct_answer)
	
	return question_text

# Funkcja do uzyskania pytania z określonego przedmiotu (nowa funkcjonalność)
func get_question_from_subject(difficulty: int, subject: QGen.Przedmiot) -> String:
	var question_data = QGen.generate_question_from_subject(difficulty, subject)
	
	if question_data == null or question_data.size() < 4:
		print("Błąd generowania pytania z przedmiotu: ", QGen.get_subject_name(subject))
		# Fallback do losowego pytania matematycznego
		question_data = QGen.generate_question(difficulty)
	
	var question_text = question_data[0]
	
	shuffled_answers = []
	for i in range(1, question_data.size()):
		shuffled_answers.append(question_data[i])
	
	var correct_answer = question_data[1]
	shuffled_answers.shuffle()
	current_correct_answer_index = shuffled_answers.find(correct_answer)
	
	return question_text

func get_answers() -> Array:
	return shuffled_answers

func is_correct_answer(selected_index: int) -> bool:
	return selected_index == current_correct_answer_index

# Funkcja do wyświetlania statystyk pytań (przydatna do debugowania)
func show_questions_statistics():
	var stats = get_subject_statistics()
	print("\n=== STATYSTYKI PYTAŃ ===")
	
	for subject_name in stats:
		print("\n" + subject_name.to_upper() + ":")
		
		for difficulty_name in stats[subject_name]:
			var difficulty_data = stats[subject_name][difficulty_name]
			print("  " + difficulty_name + " (łącznie: " + str(difficulty_data["total_questions"]) + " pytań):")
			
			for category in difficulty_data["categories"]:
				print("    - " + category["name"] + ": " + str(category["questions"]) + " pytań")
	
	print("\n========================\n")
