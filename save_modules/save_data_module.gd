# save_data_module.gd
extends RefCounted
class_name SaveDataModule

# Constants for save system
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"

var creation_date: String = ""
var save_date: String = ""

func reset_to_defaults() -> void:
	creation_date = ""
	save_date = ""

func save_game(save_name: String, player_module: PlayerDataModule, education_module: EducationDataModule, game_module: GameDataModule) -> void:
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
	
	var save_data = {
		"player_data": player_module.to_dict(),
		"education_data": education_module.to_dict(),
		"game_data": game_module.to_dict(),
		"save_name": save_name,
		"creation_date": creation_date,
		"save_date": save_date,
		"version": "2.0"  # Mark as new modular version
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		print("Game saved successfully to: " + save_path)
	else:
		push_error("Failed to open save file for writing: " + save_path)

func load_game(file_path: String, player_module: PlayerDataModule, education_module: EducationDataModule, game_module: GameDataModule) -> bool:
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
	
	# Check if this is a new modular save file or old format
	if save_data.has("version") and save_data["version"] == "2.0":
		# New modular format
		if save_data.has("player_data"):
			player_module.from_dict(save_data["player_data"])
		if save_data.has("education_data"):
			education_module.from_dict(save_data["education_data"])
		if save_data.has("game_data"):
			game_module.from_dict(save_data["game_data"])
	else:
		# Old format - load directly into modules
		_load_legacy_format(save_data, player_module, education_module, game_module)
	
	creation_date = save_data.get("creation_date", "")
	save_date = save_data.get("save_date", "")
	
	print("Game loaded successfully from: " + file_path)
	return true

func _load_legacy_format(save_data: Dictionary, player_module: PlayerDataModule, education_module: EducationDataModule, game_module: GameDataModule) -> void:
	# Load player data from old format
	player_module.weapon_name = save_data.get("weapon_name", "basic")
	player_module.energy = save_data.get("energy", 0)
	player_module.energy_max = save_data.get("energy_max", 10)
	player_module.energy_production = save_data.get("energy_production", [1, 1])
	player_module.health = save_data.get("health", 1)
	player_module.health_max = save_data.get("health_max", 1)
	player_module.weapon_cost = save_data.get("weapon_cost", 1)
	
	# Load education data from old format
	education_module.difficulty_level = save_data.get("difficulty_level", 1)
	education_module.current_subject = save_data.get("current_subject", 0)
	education_module.subject_progress = save_data.get("subject_progress", {})
	education_module.subject_statistics = save_data.get("subject_statistics", {})
	education_module.questions_history = save_data.get("questions_history", [])
	
	# Initialize if empty (for backward compatibility)
	if education_module.subject_progress.is_empty() or education_module.subject_statistics.is_empty():
		education_module.initialize_subject_progress()
	
	# Load game data from old format
	game_module.is_new = save_data.get("is_new", true)
	game_module.bg_type = save_data.get("bg_type", null)
	game_module.bg_speed = save_data.get("bg_speed", null)
	game_module.fall_speed = save_data.get("fall_speed", null)
	game_module.points = save_data.get("points", 0)
	
	# Handle explored_tiles properly
	var raw_explored_tiles = save_data.get("explored_tiles", [])
	game_module.explored_tiles = []
	for tile in raw_explored_tiles:
		if tile is Dictionary and tile.has("x") and tile.has("y"):
			game_module.explored_tiles.append(Vector2i(tile.x, tile.y))
		elif tile is Array and tile.size() == 2:
			game_module.explored_tiles.append(Vector2i(tile[0], tile[1]))
		elif tile is String:
			var parts = tile.split(",")
			if parts.size() == 2:
				game_module.explored_tiles.append(Vector2i(int(parts[0]), int(parts[1])))
	
	# Convert ship position from dictionary back to Vector2i
	var pos_dict = save_data.get("ship_position", {"x": 5, "y": 5})
	game_module.ship_position = Vector2i(pos_dict.get("x", 5), pos_dict.get("y", 5))

func load_latest_save(player_module: PlayerDataModule, education_module: EducationDataModule, game_module: GameDataModule) -> bool:
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
	
	return load_game(SAVE_DIR + save_files[0], player_module, education_module, game_module)

func get_all_save_files(education_module: EducationDataModule) -> Array:
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
					
					# Handle both old and new formats
					var difficulty = 1
					var subject = 0
					var points = 0
					var questions_count = 0
					
					if save_data.has("version") and save_data["version"] == "2.0":
						# New modular format
						if save_data.has("education_data"):
							var edu_data = save_data["education_data"]
							difficulty = edu_data.get("difficulty_level", 1)
							subject = edu_data.get("current_subject", 0)
							questions_count = edu_data.get("questions_history", []).size()
						if save_data.has("game_data"):
							var game_data = save_data["game_data"]
							points = game_data.get("points", 0)
					else:
						# Old format
						difficulty = save_data.get("difficulty_level", 1)
						subject = save_data.get("current_subject", 0)
						points = save_data.get("points", 0)
						questions_count = save_data.get("questions_history", []).size()
					
					var difficulty_name = education_module.get_difficulty_name_from_level(difficulty)
					var subject_name = education_module.get_subject_name_from_enum(subject)
					
					save_list.append({
						"path": file_path,
						"filename": file_name,
						"save_name": save_data.get("save_name", "Unknown"),
						"points": points,
						"difficulty_level": difficulty,
						"difficulty_name": difficulty_name,
						"current_subject": subject,
						"subject_name": subject_name,
						"questions_count": questions_count,
						"creation_date": save_data.get("creation_date", save_data.get("save_datetime", "Unknown")),
						"save_date": save_data.get("save_date", save_data.get("save_datetime", "Unknown"))
					})
		file_name = dir.get_next()
	dir.list_dir_end()
	save_list.sort_custom(func(a, b): return a["save_date"] > b["save_date"])
	
	return save_list

func _to_string() -> String:
	var output = ""
	output += "creation_date: " + str(creation_date) + "\n"
	output += "save_date: " + str(save_date) + "\n"
	return output
