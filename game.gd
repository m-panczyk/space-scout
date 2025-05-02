extends Control

var viewport_size:Vector2

func _enter_tree() -> void:
	$Center/SubViewport.size_2d_override = GlobalSettings.virtual_resolution
	_on_viewport_size_changed()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var fire_event = InputEventAction.new()
		fire_event.action = "game_fire"
		fire_event.pressed = event.is_double_tap()
		Input.parse_input_event(fire_event)
func _ready():
	# Connect to window resize notification
	get_viewport().connect("size_changed", _on_viewport_size_changed)
	# Initial layout check

	
func _on_viewport_size_changed():
	viewport_size = get_viewport_rect().size

	if viewport_size.x < viewport_size.y:
		# Portrait mode: hide side columns
		set_portrait_mode(true)
	else:
		# Landscape mode: show all columns
		set_portrait_mode(false)
		
func set_portrait_mode(is_portrait: bool):
	if is_portrait:
		#$Center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$Center.position = Vector2.ZERO
		$Center.size = viewport_size
		$RightSide.visible = false
		$LeftSide.visible = false
	else:
		$Center.position = Vector2(viewport_size.x/3,0)
		#$Center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		$Center.size = Vector2(viewport_size.x/3.0,viewport_size.y)
		
	print("viewport: "+str(viewport_size.x)+"/"+str(viewport_size.y))
	print("container: "+ str($Center.size)+ "on: "+ str($Center.position))
	print("subview: "+ str($Center/SubViewport.size))
