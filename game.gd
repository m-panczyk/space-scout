extends ThreeWayDisplay

var game_paused_by_transition: bool = false

func _ready():
	super()
	$Navigation.visible = GlobalSettings.virtual_navigation
	GlobalSettings.add_touch_control()
	# Connect to transition signals
	camera.transition_started.connect(_on_transition_started)
	transition_complete.connect(_on_transition_complete)
	EventBus.subscribe("start_lvl",show_gameplay)
func _exit_tree() -> void:
	EventBus.unsubscribe("start_lvl",show_gameplay)
	
func _input(event: InputEvent) -> void:
	# If transitioning and we get "press any key" input, make transition instant
	if camera.is_camera_transitioning() and is_press_any_key_input(event):
		camera.make_transition_instant()
		get_viewport().set_input_as_handled()
		return
	
	# Handle all gestures and input in one place
	if event is InputEventPanGesture and GlobalSettings.gesture_navigation:
		handle_pan_gesture(event)
		return
	
	# Handle ESC key and Android back button
	if event.is_action_released("ui_esc") or event.is_action_released("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()
		return
	
	# Handle keyboard input for panel switching (only if not transitioning and not paused)
	if not camera.is_camera_transitioning() and not is_game_paused():
		if event.is_action_pressed("panel_right"):
			switch_to_panel_to_the_right()
		elif event.is_action_pressed("panel_left"):
			switch_to_panel_to_the_left()
		elif event.is_action_pressed("show_player_stats"):
			switch_to_panel(PanelType.LEFT_PANEL)
		elif event.is_action_pressed("show_gameplay"):
			switch_to_panel(PanelType.CENTER_PANEL)
		elif event.is_action_pressed("show_map"):
			switch_to_panel(PanelType.RIGHT_PANEL)

func _notification(what):
	# Handle Android back button through notification system
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		toggle_pause()

func handle_pan_gesture(event: InputEventPanGesture):
	"""Handle all pan gestures - both panel navigation and pause/resume"""
	var pan_delta = event.delta
	
	# Vertical pan gestures for pause/resume (prioritize over horizontal)
	if abs(pan_delta.y) > abs(pan_delta.x) and abs(pan_delta.y) > 10.0:
		if pan_delta.y > 0:  # Down gesture
			pause_game()
		else:  # Up gesture
			resume_game()
		return
	
	# Horizontal pan gestures for panel navigation (only if not paused)
	if not is_game_paused() and abs(pan_delta.x) > abs(pan_delta.y) and abs(pan_delta.x) > 10.0:
		if not block_input_during_transition or not camera.is_camera_transitioning():
			if pan_delta.x < 0:
				switch_to_panel_to_the_right()
			else:
				switch_to_panel_to_the_left()

func is_press_any_key_input(event: InputEvent) -> bool:
	"""Check if event is a 'press any key' type input that should skip transitions"""
	# Key presses (but not releases or repeats)
	if event is InputEventKey and event.pressed and not event.echo:
		return true
	
	# Mouse button presses
	if event is InputEventMouseButton and event.pressed:
		return true
	
	# Screen touches
	if event is InputEventScreenTouch and event.pressed:
		return true
	
	# Joypad button presses
	if event is InputEventJoypadButton and event.pressed:
		return true
	
	return false

func _on_transition_started():
	"""Pause game during transition without showing pause menu"""
	if not is_game_paused():
		%GameLevel.process_mode = Node.PROCESS_MODE_DISABLED
		game_paused_by_transition = true

func _on_transition_complete():
	"""Resume game after transition if it was paused by transition"""
	if game_paused_by_transition:
		%GameLevel.process_mode = Node.PROCESS_MODE_INHERIT
		game_paused_by_transition = false

func is_game_paused() -> bool:
	"""Check if game is currently paused (by user, not transition)"""
	return %GameLevel.process_mode == Node.PROCESS_MODE_DISABLED and not game_paused_by_transition

func toggle_pause():
	"""Toggle pause state of the game"""
	if is_game_paused():
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
