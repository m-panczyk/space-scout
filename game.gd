extends ColorRect
var viewport_size:Vector2
var portrait_mode = false

func _enter_tree() -> void:
	$Center/SubViewport.size_2d_override = GlobalSettings.virtual_resolution

func _ready():
	if DisplayServer.is_touchscreen_available():
		var touch_controls = TouchControls.new()
		$Center/SubViewport.add_child(touch_controls)
	# Connect to window resize notification
	get_viewport().connect("size_changed", _on_viewport_size_changed)
	# Initial layout check
	_on_viewport_size_changed()
	$PausePanel/MenuContainer.current_scene.pause_menu()

	
func _on_viewport_size_changed():
	viewport_size = get_viewport_rect().size

	if viewport_size.x < viewport_size.y:
		# Portrait mode: hide side columns
		set_portrait_mode(true)
		$LeftSide.hide()
		$RightSide.hide()
		%PauseSide.show()
		for child in get_children():
			if child.is_in_group("columns"):
				child.size = viewport_size
		%HUD.position.y = 0
		%HUD.size.y = viewport_size.y*0.2
		%HUD.size.x = viewport_size.x
	else:
		# Landscape mode: show all columns
		set_portrait_mode(false)
		for child in get_children():
			if child.is_in_group("columns"):
				child.size = Vector2(viewport_size.x/3,viewport_size.y)
		%HUD.size.y = viewport_size.y*0.2

		%PauseSide.hide()
		$LeftSide.show()
		$RightSide.show()
		$RightSide.position = Vector2(viewport_size.x*2/3,0)
	
		
func set_portrait_mode(is_portrait: bool):
	portrait_mode = is_portrait
	if is_portrait:
		$Center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$Center.position = Vector2.ZERO
		$Center.size = viewport_size
		$RightSide.visible = false
		$RightSide.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$LeftSide.visible = false
		$LeftSide.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		$Center.position = Vector2(viewport_size.x/3,0)
		#$Center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		$Center.size = Vector2(viewport_size.x/3.0,viewport_size.y)

func _on_pause_side_pressed() -> void:
	$RightSide.show()
	%HUD.hide()
	if %GameLevel.env != null:
		%GameLevel.env.pause()


func _on_start_level_button_pressed() -> void:
	get_tree().call_group("MAP","prepare_lvl")
	if portrait_mode:
		$RightSide.hide()
	%GameLevel.start_lvl()
	%StartLevelButton.disabled = true
