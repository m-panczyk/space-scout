extends Panel


func _on_yes_pressed() -> void:
	GlobalSettings.set_tutorial_done($CheckButton.button_pressed)
	get_tree().change_scene_to_file("res://Tutorial.tscn")


func _on_no_pressed() -> void:
	GlobalSettings.set_tutorial_done($CheckButton.button_pressed)
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_visibility_changed() -> void:
	if visible:
		$HBoxContainer/YES.grab_focus()
