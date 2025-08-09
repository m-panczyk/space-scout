# save_data.gd - Main SaveData class that delegates to modules
extends Node

# Module instances
var player_module: PlayerDataModule
var education_module: EducationDataModule
var game_module: GameDataModule
var save_module: SaveDataModule

# Backward compatibility - proxy all existing properties to modules
var is_new:bool:
	get: return game_module.is_new
	set(value): game_module.is_new = value

var difficulty_level:int:
	get: return education_module.difficulty_level
	set(value): education_module.difficulty_level = value

var current_subject:int:
	get: return education_module.current_subject
	set(value): education_module.current_subject = value

var subject_progress:
	get: return education_module.subject_progress
	set(value): education_module.subject_progress = value

var subject_statistics:
	get: return education_module.subject_statistics
	set(value): education_module.subject_statistics = value

var questions_history:
	get: return education_module.questions_history
	set(value): education_module.questions_history = value

var bg_type:
	get: return game_module.bg_type
	set(value): game_module.bg_type = value

var bg_speed:
	get: return game_module.bg_speed
	set(value): game_module.bg_speed = value

var fall_speed:
	get: return game_module.fall_speed
	set(value): game_module.fall_speed = value

var points:
	get: return game_module.points
	set(value): game_module.points = value

var explored_tiles:
	get: return game_module.explored_tiles
	set(value): game_module.explored_tiles = value

var ship_position:
	get: return game_module.ship_position
	set(value): game_module.ship_position = value

var weapon_name:
	get: return player_module.weapon_name
	set(value): player_module.weapon_name = value

var energy:
	get: return player_module.energy
	set(value): player_module.energy = value

var energy_max:
	get: return player_module.energy_max
	set(value): player_module.energy_max = value

var energy_production:
	get: return player_module.energy_production
	set(value): player_module.energy_production = value

var health:
	get: return player_module.health
	set(value): player_module.health = value

var health_max:
	get: return player_module.health_max
	set(value): player_module.health_max = value

var weapon_cost:
	get: return player_module.weapon_cost
	set(value): player_module.weapon_cost = value

var creation_date:
	get: return save_module.creation_date
	set(value): save_module.creation_date = value

var save_date:
	get: return save_module.save_date
	set(value): save_module.save_date = value

func _ready():
	# Initialize all modules
	player_module = PlayerDataModule.new()
	education_module = EducationDataModule.new()
	game_module = GameDataModule.new()
	save_module = SaveDataModule.new()
	
	# Initialize modules
	education_module.initialize_subject_progress()

# Delegate all existing methods to appropriate modules
func add_question_to_history(question: Array, correct_answer: int, player_answer: int) -> void:
	education_module.add_question_to_history(question, correct_answer, player_answer)

func get_questions_history() -> Array:
	return education_module.get_questions_history()

func get_recent_questions(count: int = 10) -> Array:
	return education_module.get_recent_questions(count)

func get_questions_history_stats() -> Dictionary:
	return education_module.get_questions_history_stats()

func clear_questions_history() -> void:
	education_module.clear_questions_history()

func reset_to_defaults() -> void:
	player_module.reset_to_defaults()
	education_module.reset_to_defaults()
	game_module.reset_to_defaults()
	save_module.reset_to_defaults()

func update_subject_progress(subject_enum: int, is_correct: bool, answer_time: float = 0.0):
	education_module.update_subject_progress(subject_enum, is_correct, answer_time)

func process_question_answer(question: Array, correct_answer: int, player_answer: int, answer_time: float = 0.0):
	education_module.process_question_answer(question, correct_answer, player_answer, answer_time)

func get_subject_stats(subject_enum: int) -> Dictionary:
	return education_module.get_subject_stats(subject_enum)

func get_subject_accuracy(subject_enum: int) -> float:
	return education_module.get_subject_accuracy(subject_enum)

func get_subject_best_streak(subject_enum: int) -> int:
	return education_module.get_subject_best_streak(subject_enum)

func get_subject_name_from_enum(subject_enum: int) -> String:
	return education_module.get_subject_name_from_enum(subject_enum)

func get_difficulty_name_from_level(level: int) -> String:
	return education_module.get_difficulty_name_from_level(level)

func get_difficulty_name() -> String:
	return education_module.get_difficulty_name()

func get_pretty_stats() -> String:
	return education_module.get_pretty_stats()

func show_as_detailed_popup():
	education_module.show_as_detailed_popup()

func _to_string() -> String:
	var output = ""
	output += "=== PLAYER MODULE ===\n" + player_module._to_string() + "\n"
	output += "=== EDUCATION MODULE ===\n" + education_module._to_string() + "\n"
	output += "=== GAME MODULE ===\n" + game_module._to_string() + "\n"
	output += "=== SAVE MODULE ===\n" + save_module._to_string() + "\n"
	return output

# Save/Load methods delegate to save_module
func save_game(save_name: String) -> void:
	save_module.save_game(save_name, player_module, education_module, game_module)

func load_game(file_path: String) -> bool:
	return save_module.load_game(file_path, player_module, education_module, game_module)

func load_latest_save() -> bool:
	return save_module.load_latest_save(player_module, education_module, game_module)

func get_all_save_files() -> Array:
	return save_module.get_all_save_files(education_module)
