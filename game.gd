extends Control

var viewport_size:Vector2

func _enter_tree() -> void:
	$Center/SubViewport.size_2d_override = GlobalSettings.virtual_resolution

func _ready():
	if DisplayServer.is_touchscreen_available():
		var touch_controls = TouchControls.new()
		get_tree().root.add_child(touch_controls)
	# Connect to window resize notification
	get_viewport().connect("size_changed", _on_viewport_size_changed)
	# Initial layout check
	_on_viewport_size_changed()

	
func _on_viewport_size_changed():
	viewport_size = get_viewport_rect().size
	if viewport_size.x < viewport_size.y:
		# Portrait mode: hide side columns
		set_portrait_mode(true)
		$LeftSide.hide()
		$RightSide.hide()
		%HUD.show()
		for child in get_children():
			child.size = viewport_size
		%HUD.size.x = viewport_size.x
	else:
		# Landscape mode: show all columns
		set_portrait_mode(false)
		for child in get_children():
			child.size = Vector2(viewport_size.x/3,viewport_size.y)
		%HUD.hide()
		$LeftSide.show()
		$RightSide.show()
	
		
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
