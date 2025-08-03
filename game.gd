extends ThreeWayDisplay

func _input(event: InputEvent) -> void:
	super(event)
	if event.is_action_released("ui_esc"):
		var is_paused = %GameLevel.process_mode == Node.PROCESS_MODE_DISABLED
		if is_paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	%GameLevel.process_mode = Node.PROCESS_MODE_DISABLED
	%GameLevel.hide()
	%PausePanel.show()

func resume_game():
	%GameLevel.show()
	%PausePanel.hide()
	%GameLevel.process_mode = Node.PROCESS_MODE_INHERIT
