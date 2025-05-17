extends RichTextLabel

func show_question():
	text = GlobalSettings.get_question()
	var children = $HBoxContainer.get_children()
	var answers = GlobalSettings.get_answers()
	for i in range(min(children.size(), answers.size())):
		children[i].text = answers[i]
	$"../VBoxContainer".hide()
	show()

func hide_question():
	$"../VBoxContainer".show()
	hide()
