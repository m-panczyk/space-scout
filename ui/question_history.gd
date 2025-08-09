extends ItemList

func _ready() -> void:
	update_question_list()
	EventBus.subscribe("end_lvl", update_question_list)

func _exit_tree() -> void:
	EventBus.unsubscribe("end_lvl", update_question_list)

func update_question_list(_arg = null) -> void:
	clear()
	
	var questions = SaveData.get_questions_history()
	
	for i in range(questions.size()):
		var question_entry = questions[i]
		var question_data = question_entry[0]  # ["6 + 4 = ?", "10", "12", "2"]
		var correct_index = int(question_entry[1])  # 0
		var selected_index = int(question_entry[2])  # 1
		
		var question_text = question_data[0]
		var answers = question_data.slice(1)  # ["10", "12", "2"]
		var correct_answer = answers[correct_index]
		var selected_answer = answers[selected_index]
		var is_correct = correct_index == selected_index
		
		# Create detailed display text
		var result = "✓" if is_correct else "✗"
		var display_text = "%s %s | Odpowiedź: %s | Poprawna Odpowiedź: %s" % [
			result, 
			question_text, 
			selected_answer, 
			correct_answer
		]
		
		add_item(display_text)
		
		# Color code the item
		if is_correct:
			set_item_custom_bg_color(i, Color.GREEN * 0.2)
		else:
			set_item_custom_bg_color(i, Color.RED * 0.2)
