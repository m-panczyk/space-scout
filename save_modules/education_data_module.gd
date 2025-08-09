# education_data_module.gd
extends RefCounted
class_name EducationDataModule

var difficulty_level: int = 1
var current_subject: int = 0
var subject_progress: Dictionary = {}
var subject_statistics: Dictionary = {}
var questions_history: Array = []

func initialize_subject_progress():
	if subject_progress.is_empty():
		# Initialize for all subjects
		for subject in range(6):  # 6 subjects (MATEMATYKA to ANGIELSKI)
			var subject_name = get_subject_name_from_enum(subject)
			subject_progress[subject_name] = {
				"questions_answered": 0,
				"correct_answers": 0,
				"categories_unlocked": [],
				"best_streak": 0,
				"current_streak": 0
			}
			
			subject_statistics[subject_name] = {
				"total_time_spent": 0,  # in seconds
				"average_answer_time": 0,
				"difficulty_progress": {
					"10-11lat": {"answered": 0, "correct": 0},
					"12-13lat": {"answered": 0, "correct": 0},
					"14-15lat": {"answered": 0, "correct": 0}
				}
			}

func add_question_to_history(question: Array, correct_answer: int, player_answer: int) -> void:
	if question.size() != 4:
		push_error("Question array must contain exactly 4 strings (question + 3 answers)")
		return
	
	var question_entry = [question.duplicate(), correct_answer, player_answer]
	questions_history.append(question_entry)
	
	# Optionally: limit history size (e.g., to last 1000 questions)
	var max_history_size = 1000
	if questions_history.size() > max_history_size:
		questions_history = questions_history.slice(questions_history.size() - max_history_size)

func get_questions_history() -> Array:
	return questions_history.duplicate()

func get_recent_questions(count: int = 10) -> Array:
	var start_index = max(0, questions_history.size() - count)
	return questions_history.slice(start_index)

func get_questions_history_stats() -> Dictionary:
	if questions_history.is_empty():
		return {
			"total_questions": 0,
			"correct_answers": 0,
			"accuracy": 0.0,
			"recent_accuracy": 0.0  # accuracy from last 20 questions
		}
	
	var total_questions = questions_history.size()
	var correct_count = 0
	var recent_correct = 0
	var recent_count = min(20, total_questions)
	
	# Count all correct answers
	for entry in questions_history:
		var correct_answer = entry[1]
		var player_answer = entry[2]
		if correct_answer == player_answer:
			correct_count += 1
	
	# Count correct answers from last 20 questions
	var recent_questions = get_recent_questions(recent_count)
	for entry in recent_questions:
		var correct_answer = entry[1]
		var player_answer = entry[2]
		if correct_answer == player_answer:
			recent_correct += 1
	
	var accuracy = (float(correct_count) / float(total_questions)) * 100.0
	var recent_accuracy = 0.0
	if recent_count > 0:
		recent_accuracy = (float(recent_correct) / float(recent_count)) * 100.0
	
	return {
		"total_questions": total_questions,
		"correct_answers": correct_count,
		"accuracy": accuracy,
		"recent_accuracy": recent_accuracy
	}

func clear_questions_history() -> void:
	questions_history.clear()

func reset_to_defaults() -> void:
	difficulty_level = 1
	current_subject = 0
	subject_progress = {}
	subject_statistics = {}
	questions_history = []
	initialize_subject_progress()

func update_subject_progress(subject_enum: int, is_correct: bool, answer_time: float = 0.0):
	var subject_name = get_subject_name_from_enum(subject_enum)
	var difficulty_name = get_difficulty_name()
	
	# Update basic statistics
	if subject_progress.has(subject_name):
		subject_progress[subject_name]["questions_answered"] += 1
		
		if is_correct:
			subject_progress[subject_name]["correct_answers"] += 1
			subject_progress[subject_name]["current_streak"] += 1
			
			# Check if it's a new record
			if subject_progress[subject_name]["current_streak"] > subject_progress[subject_name]["best_streak"]:
				subject_progress[subject_name]["best_streak"] = subject_progress[subject_name]["current_streak"]
		else:
			subject_progress[subject_name]["current_streak"] = 0
	
	# Update detailed statistics
	if subject_statistics.has(subject_name):
		subject_statistics[subject_name]["total_time_spent"] += answer_time
		
		# Update statistics for difficulty level
		if subject_statistics[subject_name]["difficulty_progress"].has(difficulty_name):
			subject_statistics[subject_name]["difficulty_progress"][difficulty_name]["answered"] += 1
			
			if is_correct:
				subject_statistics[subject_name]["difficulty_progress"][difficulty_name]["correct"] += 1
		
		# Calculate average answer time
		var total_questions = subject_progress[subject_name]["questions_answered"]
		if total_questions > 0:
			subject_statistics[subject_name]["average_answer_time"] = subject_statistics[subject_name]["total_time_spent"] / total_questions

func process_question_answer(question: Array, correct_answer: int, player_answer: int, answer_time: float = 0.0):
	# Add question to history
	add_question_to_history(question, correct_answer, player_answer)
	
	# Update subject progress
	var is_correct = (correct_answer == player_answer)
	update_subject_progress(current_subject, is_correct, answer_time)

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

func get_subject_accuracy(subject_enum: int) -> float:
	var subject_name = get_subject_name_from_enum(subject_enum)
	
	if not subject_progress.has(subject_name):
		return 0.0
	
	var total = subject_progress[subject_name]["questions_answered"]
	var correct = subject_progress[subject_name]["correct_answers"]
	
	if total == 0:
		return 0.0
	
	return (float(correct) / float(total)) * 100.0

func get_subject_best_streak(subject_enum: int) -> int:
	var subject_name = get_subject_name_from_enum(subject_enum)
	
	if not subject_progress.has(subject_name):
		return 0
	
	return subject_progress[subject_name]["best_streak"]

func get_subject_name_from_enum(subject_enum: int) -> String:
	match subject_enum:
		0: return "Matematyka"      # QGen.Przedmiot.MATEMATYKA
		1: return "Geografia"       # QGen.Przedmiot.GEOGRAFIA
		2: return "Historia"        # QGen.Przedmiot.HISTORIA
		3: return "Przyroda"        # QGen.Przedmiot.PRZYRODA
		4: return "Polski"          # QGen.Przedmiot.POLSKI
		5: return "Angielski"       # QGen.Przedmiot.ANGIELSKI
		_: return "Nieznany"

func get_difficulty_name_from_level(level: int) -> String:
	match level:
		0: return "10-11 lat"
		1: return "12-13 lat"
		2: return "14-15 lat"
		_: return "Nieznany"

func get_difficulty_name() -> String:
	return get_difficulty_name_from_level(difficulty_level)

func get_pretty_stats() -> String:
	var bbtext = "\n\n"

	bbtext += "[color=#ffff00]poziom_trudności:[/color] [b]" + get_difficulty_name() + "[/b]\n"
	bbtext += "[color=#ffff00]aktualny_przedmiot:[/color] [b]" + get_subject_name_from_enum(current_subject) + "[/b]\n"
	
	# Add question history statistics
	var history_stats = get_questions_history_stats()
	bbtext += "\n[color=#00ff00]--- Historia Pytań ---[/color]\n"
	bbtext += "[color=#ffff00]wszystkich_pytań:[/color] [b]" + str(history_stats["total_questions"]) + "[/b]\n"
	bbtext += "[color=#ffff00]dokładność_ogólna:[/color] [b]" + str(int(history_stats["accuracy"])) + "%[/b]\n"
	bbtext += "[color=#ffff00]dokładność_ostatnich_20:[/color] [b]" + str(int(history_stats["recent_accuracy"])) + "%[/b]\n"
	
	# Add statistics for current subject
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
	popup.title = "Szczegóły Edukacji"
	
	var rtl = RichTextLabel.new()
	rtl.bbcode_enabled = true
	
	var bbtext = "[b]Dane Edukacyjne[/b]\n\n"
	bbtext += "[color=#ffff00]difficulty_level:[/color] " + get_difficulty_name() + "\n"
	bbtext += "[color=#ffff00]current_subject:[/color] " + get_subject_name_from_enum(current_subject) + "\n"
	
	# Add detailed question history statistics
	var history_stats = get_questions_history_stats()
	bbtext += "\n[b][color=#ff6600]=== HISTORIA PYTAŃ ===[/color][/b]\n"
	bbtext += "Wszystkich pytań: [b]" + str(history_stats["total_questions"]) + "[/b]\n"
	bbtext += "Poprawnych odpowiedzi: [b]" + str(history_stats["correct_answers"]) + "[/b]\n"
	bbtext += "Dokładność ogólna: [b]" + str(int(history_stats["accuracy"])) + "%[/b]\n"
	bbtext += "Dokładność ostatnich 20: [b]" + str(int(history_stats["recent_accuracy"])) + "%[/b]\n"
	
	# Add detailed subject statistics
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
		
		# Add time statistics if available
		if subject_statistics.has(subject_name):
			var stats = subject_statistics[subject_name]
			var avg_time = stats["average_answer_time"]
			var total_time_minutes = stats["total_time_spent"] / 60.0
			
			bbtext += "  Średni czas odpowiedzi: [b]" + str(int(avg_time * 100) / 100.0) + "s[/b]\n"
			bbtext += "  Łączny czas: [b]" + str(int(total_time_minutes * 10) / 10.0) + " min[/b]\n"
	
	rtl.text = bbtext
	rtl.custom_minimum_size = Vector2(500, 400)
	
	popup.add_child(rtl)
	
	var root = Engine.get_main_loop().current_scene.get_tree().root
	root.add_child(popup)
	
	popup.popup_centered()
	
	popup.connect("confirmed", func(): popup.queue_free())
	popup.connect("close_requested", func(): popup.queue_free())

func to_dict() -> Dictionary:
	return {
		"difficulty_level": difficulty_level,
		"current_subject": current_subject,
		"subject_progress": subject_progress,
		"subject_statistics": subject_statistics,
		"questions_history": questions_history
	}

func from_dict(data: Dictionary) -> void:
	difficulty_level = data.get("difficulty_level", 1)
	current_subject = data.get("current_subject", 0)
	subject_progress = data.get("subject_progress", {})
	subject_statistics = data.get("subject_statistics", {})
	questions_history = data.get("questions_history", [])
	
	# Initialize if empty (for backward compatibility)
	if subject_progress.is_empty() or subject_statistics.is_empty():
		initialize_subject_progress()

func _to_string() -> String:
	var output = ""
	output += "difficulty_level: " + get_difficulty_name() + "\n"
	output += "current_subject: " + get_subject_name_from_enum(current_subject) + "\n"
	
	# Add question history statistics
	var history_stats = get_questions_history_stats()
	output += "\n=== HISTORIA PYTAŃ ===\n"
	output += "Wszystkich pytań: " + str(history_stats["total_questions"]) + "\n"
	output += "Poprawnych odpowiedzi: " + str(history_stats["correct_answers"]) + "\n"
	output += "Dokładność ogólna: " + str(int(history_stats["accuracy"])) + "%\n"
	output += "Dokładność ostatnich 20: " + str(int(history_stats["recent_accuracy"])) + "%\n"
	
	# Add subject statistics
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
