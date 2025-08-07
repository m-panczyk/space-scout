extends Node

var game_progress=20

var current_correct_answer_index: int = 0
var shuffled_answers: Array = []
var question_text = ''
var question_data

func set_question():
	question_data = QGen.generate_question_from_subject(SaveData.difficulty_level,SaveData.current_subject)
	# Pobierz tekst pytania (pierwszy element)
	question_text = question_data[0]
	
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
	question_data = [question_text]
	question_data.append_array(shuffled_answers)
	

func get_question() -> String:
	return question_text
func get_answers() -> Array:
	return shuffled_answers

func is_correct_answer(selected_index: int) -> bool:
	SaveData.questions_history.append([question_data,current_correct_answer_index,selected_index])
	return selected_index == current_correct_answer_index
