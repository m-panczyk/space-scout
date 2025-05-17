extends ColorRect

func _input(event: InputEvent) -> void:
	if event.is_released() and event.is_action("ui_cancel"):
		if visible:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()
