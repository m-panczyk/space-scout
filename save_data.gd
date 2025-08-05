extends Node

var is_new:bool = true

# Difficulty level (0 = 10-11lat, 1 = 12-13lat, 2 = 14-15lat)
var difficulty_level:int = 1

# Nowe zmienne dla systemu przedmiotów
var current_subject:int = 0  # QGen.Przedmiot.MATEMATYKA
var subject_progress = {}  # Postęp w różnych przedmiotach
var subject_statistics = {}  # Statystyki dla przedmiotów

var game_progress

var bg_type 
var bg_speed
var fall_speed

var points = 0
var explored_tiles = []
var ship_position = Vector2i(5,5)

var weapon_name = 'basic'
var energy = 0
var energy_max = 10
var energy_production = [1,1]

var health = 10
var health_max = 10

# Date when the save was created
var creation_date:String = ""
var save_date:String = ""

# Constants for save system
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"

func _ready():
	# Ensure the save directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	# Initialize subject progress tracking
	initialize_subject_progress()

# Inicjalizacja postępu dla wszystkich przedmiotów
func initialize_subject_progress():
	if subject_progress.is_empty():
		# Inicjalizuj dla wszystkich przedmiotów
		for subject in range(6):  # 6 przedmiotów (MATEMATYKA do ANGIELSKI)
			var subject_name = get_subject_name_from_enum(subject)
			subject_progress[subject_name] = {
				"questions_answered": 0,
				"correct_answers": 0,
				"categories_unlocked": [],
				"best_streak": 0,
				"current_streak": 0
			}
			
			subject_statistics[subject_name] = {
				"total_time_spent": 0,  # w sekundach
				"average_answer_time": 0,
				"difficulty_progress": {
					"10-11lat": {"answered": 0, "correct": 0},
					"12-13lat": {"answered": 0, "correct": 0},
					"14-15lat": {"answered": 0, "correct": 0}
				}
			}

# Resets all game state variables to their default values
func reset_to_defaults() -> void:
	is_new = true
	difficulty_level = 1
	current_subject = 0  # QGen.Przedmiot.MATEMATYKA
	subject_progress = {}
	subject_statistics = {}
	
	bg_type = null
	bg_speed = null
	fall_speed = null
	points = 0
	explored_tiles = []
	ship_position = Vector2i(5, 5)
	weapon_name = 'basic'
	energy = 0
	energy_max = 10
	energy_production = [1, 1]
	health = 1
	health_max = 1
	creation_date = ""
	save_date = ""
	
	initialize_subject_progress()

# Funkcja do aktualizacji postępu w przedmiocie
func update_subject_progress(subject_enum: int, is_correct: bool, answer_time: float = 0.0):
	var subject_name = get_subject_name_from_enum(subject_enum)
	var difficulty_name = get_difficulty_name()
	
	# Aktualizuj podstawowe statystyki
	if subject_progress.has(subject_name):
		subject_progress[subject_name]["questions_answered"] += 1
		
		if is_correct:
			subject_progress[subject_name]["correct_answers"] += 1
			subject_progress[subject_name]["current_streak"] += 1
			
			# Sprawdź czy to nowy rekord
			if subject_progress[subject_name]["current_streak"] > subject_progress[subject_name]["best_streak"]:
				subject_progress[subject_name]["best_streak"] = subject_progress[subject_name]["current_streak"]
		else:
			subject_progress[subject_name]["current_streak"] = 0
	
	# Aktualizuj szczegółowe statystyki
	if subject_statistics.has(subject_name):
		subject_statistics[subject_name]["total_time_spent"] += answer_time
		
		# Aktualizuj statystyki dla poziomu trudności
		if subject_statistics[subject_name]["difficulty_progress"].has(difficulty_name):
			subject_statistics[subject_name]["difficulty_progress"][difficulty_name]["answered"] += 1
			
			if is_correct:
				subject_statistics[subject_name]["difficulty_progress"][difficulty_name]["correct"] += 1
		
		# Oblicz średni czas odpowiedzi
		var total_questions = subject_progress[subject_name]["questions_answered"]
		if total_questions > 0:
			subject_statistics[subject_name]["average_answer_time"] = subject_statistics[subject_name]["total_time_spent"] / total_questions

# Funkcja pobierająca statystyki dla przedmiotu
func get_subject_stats(subject_enum: int) -> Dictionary:
	var subject_name = get_subject_name_from_enum(subject_enum)
	
	var stats = {
		"progress": {},
		"statistics": {}
	}
	
	if subject_progress.has(subject_name):
		stats["progress"] = subject_progress[subject_name]
	
	if subject_statistics.has(subject_name):
		stats["statistics"] = subject_statistics[subject_name]
	
	return stats

# Funkcja pobierająca procent poprawnych odpowiedzi dla przedmiotu
func get_subject_accuracy(subject_enum: int) -> float:
	var subject_name = get_subject_name_from_enum(subject_enum)
	
	if not subject_progress.has(subject_name):
		return 0.0
	
	var total = subject_progress[subject_name]["questions_answered"]
	var correct = subject_progress[subject_name]["correct_answers"]
	
	if total == 0:
		return 0.0
	
	return (float(correct) / float(total)) * 100.0

# Funkcja pobierająca najlepszy wynik (streak) dla przedmiotu
func get_subject_best_streak(subject_enum: int) -> int:
	var subject_name = get_subject_name_from_enum(subject_enum)
	
	if not subject_progress.has(subject_name):
		return 0
	
	return subject_progress[subject_name]["best_streak"]

# Funkcja konwertująca enum przedmiotu na nazwę
func get_subject_name_from_enum(subject_enum: int) -> String:
	match subject_enum:
		0: return "Matematyka"      # QGen.Przedmiot.MATEMATYKA
		1: return "Geografia"       # QGen.Przedmiot.GEOGRAFIA
		2: return "Historia"        # QGen.Przedmiot.HISTORIA
		3: return "Przyroda"        # QGen.Przedmiot.PRZYRODA
		4: return "Polski"          # QGen.Przedmiot.POLSKI
		5: return "Angielski"       # QGen.Przedmiot.ANGIELSKI
		_: return "Nieznany"

# Nowa funkcja do konwersji poziomu na nazwę (kompatybilna z nowym systemem)
func get_difficulty_name_from_level(level: int) -> String:
	match level:
		0: return "10-11 lat"
		1: return "12-13 lat"
		2: return "14-15 lat"
		_: return "Nieznany"

func _to_string() -> String:
	var output = ""
	output += "is_new: " + str(is_new) + "\n"
	output += "difficulty_level: " + get_difficulty_name() + "\n"
	output += "current_subject: " + get_subject_name_from_enum(current_subject) + "\n"
	output += "bg_type: " + str(bg_type) + "\n"
	output += "bg_speed: " + str(bg_speed) + "\n"
	output += "fall_speed: " + str(fall_speed) + "\n"
	output += "points: " + str(points) + "\n"
	output += "explored_tiles: " + str(explored_tiles.size()) + " tiles\n"
	output += "ship_position: " + str(ship_position) + "\n"
	output += "weapon_name: " + str(weapon_name) + "\n"
	output += "energy: " + str(energy) + "/" + str(energy_max) + "\n"
	output += "energy_production: " + str(energy_production) + "\n"
	output += "creation_date: " + str(creation_date) + "\n"
	output += "save_date: " + str(save_date) + "\n"
	
	# Dodaj statystyki przedmiotów
	output += "\n=== STATYSTYKI PRZEDMIOTÓW ===\n"
	for subject_name in subject_progress:
		var progress = subject_progress[subject_name]
		var accuracy = 0.0
		if progress["questions_answered"] > 0:
			accuracy = (float(progress["correct_answers"]) / float(progress["questions_answered"])) * 100.0
		
		output += subject_name + ": " + str(progress["questions_answered"]) + " pytań, " 
		output += str(progress["correct_answers"]) + " poprawnych (" + str(int(accuracy)) + "%), "
		output += "najlepszy streak: " + str(progress["best_streak"]) + "\n"
	
	return output

# Helper function to get difficulty name from level
func get_difficulty_name() -> String:
	return get_difficulty_name_from_level(difficulty_level)

func get_pretty_stats() -> String:
	var bbtext = "\n\n"

	bbtext += "[color=#ffff00]poziom_trudności:[/color] [b]" + get_difficulty_name() + "[/b]\n"
	bbtext += "[color=#ffff00]aktualny_przedmiot:[/color] [b]" + get_subject_name_from_enum(current_subject) + "[/b]\n"
	bbtext += "[color=#ffff00]punkty:[/color] [b]" + str(points) + "[/b]\n"
	bbtext += "[color=#ffff00]odkryte_kafelki:[/color] [b]" + str(explored_tiles.size()) + "[/b] kafelki\n"
	
	# Dodaj statystyki dla aktualnego przedmiotu
	var current_subject_name = get_subject_name_from_enum(current_subject)
	if subject_progress.has(current_subject_name):
		var progress = subject_progress[current_subject_name]
		var accuracy = get_subject_accuracy(current_subject)
		
		bbtext += "\n[color=#00ff00]--- " + current_subject_name + " ---[/color]\n"
		bbtext += "[color=#ffff00]pytania:[/color] [b]" + str(progress["questions_answered"]) + "[/b]\n"
		bbtext += "[color=#ffff00]poprawne:[/color] [b]" + str(progress["correct_answers"]) + "[/b] (" + str(int(accuracy)) + "%)\n"
		bbtext += "[color=#ffff00]najlepszy_streak:[/color] [b]" + str(progress["best_streak"]) + "[/b]\n"
		bbtext += "[color=#ffff00]aktualny_streak:[/color] [b]" + str(progress["current_streak"]) + "[/b]\n"

	return bbtext

func show_as_detailed_popup():
	var popup = AcceptDialog.new()
	popup.title = "Szczegóły Gry"
	
	var rtl = RichTextLabel.new()
	rtl.bbcode_enabled = true
	
	var bbtext = "[b]Dane Gry[/b]\n\n"
	bbtext += "[color=#ffff00]is_new:[/color] " + str(is_new) + "\n"
	bbtext += "[color=#ffff00]difficulty_level:[/color] " + get_difficulty_name() + "\n"
	bbtext += "[color=#ffff00]current_subject:[/color] " + get_subject_name_from_enum(current_subject) + "\n"
	bbtext += "[color=#ffff00]points:[/color] " + str(points) + "\n"
	bbtext += "[color=#ffff00]explored_tiles:[/color] " + str(explored_tiles.size()) + " tiles\n"
	bbtext += "[color=#ffff00]ship_position:[/color] " + str(ship_position) + "\n"
	bbtext += "[color=#ffff00]creation_date:[/color] " + str(creation_date) + "\n"
	bbtext += "[color=#ffff00]save_date:[/color] " + str(save_date) + "\n"
	
	# Dodaj szczegółowe statystyki przedmiotów
	bbtext += "\n[b][color=#00ff00]=== STATYSTYKI PRZEDMIOTÓW ===[/color][/b]\n"
	for subject_name in subject_progress:
		var progress = subject_progress[subject_name]
		var accuracy = 0.0
		if progress["questions_answered"] > 0:
			accuracy = (float(progress["correct_answers"]) / float(progress["questions_answered"])) * 100.0
		
		bbtext += "\n[color=#00ffff]" + subject_name + ":[/color]\n"
		bbtext += "  Pytania: [b]" + str(progress["questions_answered"]) + "[/b]\n"
		bbtext += "  Poprawne: [b]" + str(progress["correct_answers"]) + "[/b] (" + str(int(accuracy)) + "%)\n"
		bbtext += "  Najlepszy streak: [b]" + str(progress["best_streak"]) + "[/b]\n"
		bbtext += "  Aktualny streak: [b]" + str(progress["current_streak"]) + "[/b]\n"
		
		# Dodaj statystyki czasowe jeśli dostępne
		if subject_statistics.has(subject_name):
			var stats = subject_statistics[subject_name]
			var avg_time = stats["average_answer_time"]
			var total_time_minutes = stats["total_time_spent"] / 60.0
			
			bbtext += "  Średni czas odpowiedzi: [b]" + str(int(avg_time * 100) / 100.0) + "s[/b]\n"
			bbtext += "  Łączny czas: [b]" + str(int(total_time_minutes * 10) / 10.0) + " min[/b]\n"
	
	rtl.text = bbtext
	rtl.custom_minimum_size = Vector2(500, 400)
	
	popup.add_child(rtl)
	
	var root = get_tree().root
	root.add_child(popup)
	
	popup.popup_centered()
	
	popup.connect("confirmed", func(): popup.queue_free())
	popup.connect("close_requested", func(): popup.queue_free())

# Saves the current game state to a file
func save_game(save_name: String) -> void:
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		datetime["year"], 
		datetime["month"], 
		datetime["day"],
		datetime["hour"], 
		datetime["minute"], 
		datetime["second"]
	]
	
	if creation_date == "":
		creation_date = timestamp
	save_date = timestamp
	var save_path = SAVE_DIR + save_name + SAVE_EXTENSION
	
	var serialized_tiles = []
	for tile in explored_tiles:
		if tile is Vector2i:
			serialized_tiles.append({
				"x": tile.x,
				"y": tile.y
			})
		else:
			push_error("Unexpected type in explored_tiles: " + str(typeof(tile)))
	
	var save_data = {
		"is_new": is_new,
		"difficulty_level": difficulty_level,
		"current_subject": current_subject,
		"subject_progress": subject_progress,
		"subject_statistics": subject_statistics,
		"bg_type": bg_type,
		"bg_speed": bg_speed,
		"fall_speed": fall_speed,
		"points": points,
		"explored_tiles": serialized_tiles,
		"ship_position": {
			"x": ship_position.x,
			"y": ship_position.y
		},
		"weapon_name": weapon_name,
		"energy": energy,
		"energy_max": energy_max,
		"energy_production": energy_production,
		"health": health,
		"health_max": health_max,
		"save_name": save_name,
		"creation_date": creation_date,
		"save_date": save_date
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		print("Game saved successfully to: " + save_path)
	else:
		push_error("Failed to open save file for writing: " + save_path)

# Loads a game from a specific save file path
func load_game(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("Save file does not exist: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: " + file_path)
		return false
	
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse save file JSON: " + file_path)
		return false
	
	var save_data = json.get_data()
	
	# Load basic game state
	is_new = save_data.get("is_new", true)
	difficulty_level = save_data.get("difficulty_level", 1)
	current_subject = save_data.get("current_subject", 0)
	
	# Load subject progress (with fallback to empty if not present)
	subject_progress = save_data.get("subject_progress", {})
	subject_statistics = save_data.get("subject_statistics", {})
	
	# Initialize if empty (for backward compatibility)
	if subject_progress.is_empty() or subject_statistics.is_empty():
		initialize_subject_progress()
	
	bg_type = save_data.get("bg_type", null)
	bg_speed = save_data.get("bg_speed", null)
	fall_speed = save_data.get("fall_speed", null)
	points = save_data.get("points", 0)
	
	# Handle explored_tiles properly
	var raw_explored_tiles = save_data.get("explored_tiles", [])
	explored_tiles = []
	for tile in raw_explored_tiles:
		if tile is Dictionary and tile.has("x") and tile.has("y"):
			explored_tiles.append(Vector2i(tile.x, tile.y))
		elif tile is Array and tile.size() == 2:
			explored_tiles.append(Vector2i(tile[0], tile[1]))
		elif tile is String:
			var parts = tile.split(",")
			if parts.size() == 2:
				explored_tiles.append(Vector2i(int(parts[0]), int(parts[1])))
	
	# Convert ship position from dictionary back to Vector2i
	var pos_dict = save_data.get("ship_position", {"x": 5, "y": 5})
	ship_position = Vector2i(pos_dict.get("x", 5), pos_dict.get("y", 5))
	
	weapon_name = save_data.get("weapon_name", "basic")
	energy = save_data.get("energy", 0)
	energy_max = save_data.get("energy_max", 10)
	energy_production = save_data.get("energy_production", [1, 1])
	health = save_data.get("health", 1)
	health_max = save_data.get("health_max", 1)
	creation_date = save_data.get("creation_date", "")
	save_date = save_data.get("save_date", "")
	
	print("Game loaded successfully from: " + file_path)
	return true

# Loads the most recent save file
func load_latest_save() -> bool:
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		push_error("Failed to open saves directory")
		return false
	
	var save_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
			save_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if save_files.size() == 0:
		push_error("No save files found")
		return false
	
	save_files.sort()
	save_files.reverse() # Most recent first
	
	return load_game(SAVE_DIR + save_files[0])

# Get a list of all save files with their details including difficulty level
func get_all_save_files() -> Array:
	var save_list = []
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		push_error("Failed to open saves directory")
		return save_list
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
			var file_path = SAVE_DIR + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json_string = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_string)
				if error == OK:
					var save_data = json.get_data()
					var difficulty = save_data.get("difficulty_level", 1)
					var subject = save_data.get("current_subject", 0)
					var difficulty_name = get_difficulty_name_from_level(difficulty)
					var subject_name = get_subject_name_from_enum(subject)
					
					save_list.append({
						"path": file_path,
						"filename": file_name,
						"save_name": save_data.get("save_name", "Unknown"),
						"points": save_data.get("points", 0),
						"difficulty_level": difficulty,
						"difficulty_name": difficulty_name,
						"current_subject": subject,
						"subject_name": subject_name,
						"creation_date": save_data.get("creation_date", save_data.get("save_datetime", "Unknown")),
						"save_date": save_data.get("save_date", save_data.get("save_datetime", "Unknown"))
					})
			file_name = dir.get_next()
	dir.list_dir_end()
	save_list.sort_custom(func(a, b): return a["save_date"] > b["save_date"])
	
	return save_list
