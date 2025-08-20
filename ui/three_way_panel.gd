# Enhanced three_way_panel.gd - Forwards ALL InputEvents
class_name ThreeWayPanel
extends Node3D

## Individual panel component for ThreeWayDisplay system
## Manages a Sprite3D with SubViewport content
## Now forwards ALL input events, not just clicks

signal content_loaded(panel: ThreeWayPanel)
signal content_changed(panel: ThreeWayPanel)
signal panel_touched(panel: ThreeWayPanel)

@export var panel_size: Vector2i = Vector2i(1080, 1920) : set = set_panel_size
@export var pixel_size: float = 0.01
@export var enabled: bool = true : set = set_panel_enabled
@export var panel_type:ThreeWayDisplay.PanelType = ThreeWayDisplay.PanelType.CENTER_PANEL
@export var focus_node:Control

@export var sprite3d: Sprite3D
@export var viewport: SubViewport
var content_instance: Node
var viewport_texture: ViewportTexture
var click_area: Area3D
var collision_shape: CollisionShape3D
var last_click_time: float = 0.0
var double_click_threshold: float = 0.3

# Input handling state
var is_mouse_inside: bool = false
var last_mouse_position: Vector2
var mouse_inside_viewport: bool = false

# Reference to the camera for checking visibility
var camera_ref: ThreeWayCamera3D

func _ready():
	if focus_node != null:
		setup_content_input_handling(focus_node)
	find_components()
	setup_click_detection()
	find_camera_reference()
	
	# Enable input processing for this node
	set_process_input(true)

func _input(event: InputEvent):
	"""Process all input events and forward relevant ones to viewport"""
	if not enabled:
		return
	
	# For keyboard and gamepad events, forward if this panel has focus or is fully visible
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if is_panel_fully_visible() or has_input_focus():
			forward_input_to_viewport(event)
		return

func has_input_focus() -> bool:
	"""Check if this panel should receive input focus"""
	# This could be expanded based on your game's focus system
	return is_panel_fully_visible()

func handle_mouse_motion_global(event: InputEventMouseMotion):
	"""Handle global mouse motion - only forward if mouse is over this panel"""
	if mouse_inside_viewport:
		forward_mouse_motion_to_viewport(event)

func forward_keyboard_input(event: InputEventKey):
	"""Forward keyboard input to viewport"""
	var new_event = InputEventKey.new()
	new_event.keycode = event.keycode
	new_event.physical_keycode = event.physical_keycode
	new_event.unicode = event.unicode
	new_event.pressed = event.pressed
	new_event.echo = event.echo
	
	# Copy modifiers
	new_event.shift_pressed = event.shift_pressed
	new_event.ctrl_pressed = event.ctrl_pressed
	new_event.alt_pressed = event.alt_pressed
	new_event.meta_pressed = event.meta_pressed
	
	print("Forwarding keyboard input to panel ", name, ": ", event.as_text())
	viewport.push_input(new_event)
	
	# Also send to first child if it's a Control
	if viewport.get_child_count() > 0:
		var first_child = viewport.get_child(0)
		if first_child is Control:
			first_child._gui_input(new_event)

func forward_joypad_input(event: InputEvent):
	"""Forward joystick/gamepad input to viewport"""
	var new_event: InputEvent
	
	if event is InputEventJoypadButton:
		var joy_button = InputEventJoypadButton.new()
		joy_button.device = event.device
		joy_button.button_index = event.button_index
		joy_button.pressed = event.pressed
		new_event = joy_button
	elif event is InputEventJoypadMotion:
		var joy_motion = InputEventJoypadMotion.new()
		joy_motion.device = event.device
		joy_motion.axis = event.axis
		joy_motion.axis_value = event.axis_value
		new_event = joy_motion
	
	if new_event:
		print("Forwarding joypad input to panel ", name, ": ", event.as_text())
		viewport.push_input(new_event)
		
		# Also send to first child if it's a Control
		if viewport.get_child_count() > 0:
			var first_child = viewport.get_child(0)
			if first_child is Control:
				first_child._gui_input(new_event)

func find_camera_reference():
	"""Find the ThreeWayCamera3D in the scene"""
	# Look for camera in parent hierarchy
	var current = get_parent()
	while current:
		var camera = current.get_node_or_null("ThreeWayCamera3D")
		if camera and camera is ThreeWayCamera3D:
			camera_ref = camera
			break
		current = current.get_parent()

func find_components():
	"""Find required components - throw errors if missing"""
	# Find SubViewport
	if viewport == null:
		viewport = get_node_or_null("PanelViewport")
	if not viewport:
		push_error("ThreeWayPanel (" + name + "): Missing PanelViewport child node")
		return
	
	# Find Sprite3D
	if sprite3d == null:
		sprite3d = get_node_or_null("PanelSprite")
	if not sprite3d:
		push_error("ThreeWayPanel (" + name + "): Missing PanelSprite child node")
		return
	
	# Get viewport texture
	viewport_texture = viewport.get_texture()
	
	# Set initial properties
	#viewport.size = panel_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sprite3d.pixel_size = pixel_size
	sprite3d.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	
	# Enable viewport to handle physics and input
	viewport.physics_object_picking = true
	viewport.handle_input_locally = false

func setup_click_detection():
	"""Set up Area3D for all input detection"""
	click_area = Area3D.new()
	click_area.name = "InputArea"
	add_child(click_area)
	
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "InputShape"
	click_area.add_child(collision_shape)
	
	# Create box shape matching sprite size
	var box_shape = BoxShape3D.new()
	var world_size = get_world_size()
	box_shape.size = Vector3(world_size.x, world_size.y, 0.1)
	collision_shape.shape = box_shape
	
	# Connect all input and mouse signals
	click_area.input_event.connect(_on_area_input_event)
	click_area.mouse_entered.connect(_on_mouse_entered_area)
	click_area.mouse_exited.connect(_on_mouse_exited_area)

func _on_mouse_entered_area():
	"""Called when mouse enters the panel area"""
	is_mouse_inside = true
	mouse_inside_viewport = true
	print("Mouse entered panel: ", name)

func _on_mouse_exited_area():
	"""Called when mouse exits the panel area"""
	is_mouse_inside = false
	mouse_inside_viewport = false
	print("Mouse exited panel: ", name)

func forward_mouse_motion_to_viewport(event: InputEventMouseMotion):
	"""Forward mouse motion to viewport when mouse is inside panel"""
	if not mouse_inside_viewport:
		return
	
	# We need to convert screen mouse position to panel-local coordinates
	# This is more complex for mouse motion since we need the actual screen position
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	if not camera:
		return
	
	# Raycast from camera through mouse position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# Check intersection with panel
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = click_area.collision_layer
	
	var result = space_state.intersect_ray(query)
	if result and result.collider == click_area:
		var viewport_pos = convert_click_to_viewport_coords(result.position)
		if viewport_pos != Vector2(-1, -1):
			var new_event = InputEventMouseMotion.new()
			new_event.position = viewport_pos
			new_event.global_position = viewport_pos
			new_event.relative = event.relative
			new_event.velocity = event.velocity
			
			# Copy button states
			new_event.button_mask = event.button_mask
			
			viewport.push_input(new_event)

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle ALL input events on the panel - much simpler approach"""
	if not enabled:
		return
	
	# Handle special cases for focus/panel switching
	if event is InputEventScreenTouch and event.pressed:
		if not is_panel_fully_visible():
			panel_touched.emit(self)
			return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if not is_panel_fully_visible():
			panel_touched.emit(self)
			return
	
	# Handle gameplay events for center panel
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and panel_type == ThreeWayDisplay.PanelType.CENTER_PANEL:
		if event.pressed:
			var viewport_pos = convert_click_to_viewport_coords(position)
			if event.double_click:
				EventBus.emit("gameplay_double_clicked", viewport_pos)
			else:
				EventBus.emit("gameplay_clicked", viewport_pos)
		else:
			EventBus.emit("gameplay_click_released", convert_click_to_viewport_coords(position))
	
	# Forward ALL events to viewport (this is the magic!)
	forward_input_to_viewport(event, position)

func handle_mouse_button_event(event: InputEventMouseButton, position: Vector3):
	"""Handle mouse button events"""
	# Right-click: focus on panel if not fully visible (like touch behavior)
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if not is_panel_fully_visible():
			panel_touched.emit(self)
			return
		forward_input_to_viewport(event, position)
		return
	
	# Left-click handling
	if event.button_index == MOUSE_BUTTON_LEFT:
		# Always forward to viewport content first
		forward_input_to_viewport(event, position)
		
		if event.pressed and panel_type == ThreeWayDisplay.PanelType.CENTER_PANEL:
			if event.double_click:
				# Double-click detected
				EventBus.emit("gameplay_double_clicked", convert_click_to_viewport_coords(position))
			else:
				# Single click
				EventBus.emit("gameplay_clicked", convert_click_to_viewport_coords(position))
		else:
			# Mouse released
			EventBus.emit("gameplay_click_released", convert_click_to_viewport_coords(position))
		return
	
	# Forward any other mouse buttons
	forward_input_to_viewport(event, position)

func handle_touch_event(event: InputEventScreenTouch, position: Vector3):
	"""Handle touch-specific events"""
	if not event.pressed:
		forward_input_to_viewport(event, position)
		return
	
	# On touch devices, if panel is not fully visible, focus on it instead of forwarding touch
	if not is_panel_fully_visible():
		panel_touched.emit(self)
		return
	
	# Panel is fully visible, forward touch to viewport content
	forward_input_to_viewport(event, position)

func handle_mouse_motion_event(event: InputEventMouseMotion, position: Vector3):
	"""Handle mouse motion events from Area3D"""
	forward_input_to_viewport(event, position)

func handle_screen_drag_event(event: InputEventScreenDrag, position: Vector3):
	"""Handle screen drag events"""
	forward_input_to_viewport(event, position)

func handle_magnify_gesture_event(event: InputEventMagnifyGesture, position: Vector3):
	"""Handle magnify/pinch gesture events"""
	forward_input_to_viewport(event, position)

func handle_pan_gesture_event(event: InputEventPanGesture, position: Vector3):
	"""Handle pan gesture events"""
	forward_input_to_viewport(event, position)

func forward_generic_input_event(event: InputEvent, position: Vector3):
	"""Forward any other type of input event"""
	print("Forwarding generic input event to panel ", name, ": ", event.get_class())
	forward_input_to_viewport(event, position)

func is_panel_fully_visible() -> bool:
	"""Check if this panel is fully visible in the camera view"""
	if not camera_ref:
		find_camera_reference()
		if not camera_ref:
			return true  # Assume visible if can't find camera
	
	return camera_ref.is_panel_fully_visible(sprite3d)

func forward_input_to_viewport(event: InputEvent, position: Vector3 = Vector3.ZERO):
	"""Forward any input event to the viewport content - Universal approach"""
	var new_event: InputEvent
	
	# For events that need position conversion (mouse, touch, gestures)
	if event is InputEventMouseButton or event is InputEventScreenTouch or \
	   event is InputEventMouseMotion or event is InputEventScreenDrag or \
	   event is InputEventMagnifyGesture or event is InputEventPanGesture:
		
		# Only convert position for positional events when we have a valid position
		if position != Vector3.ZERO:
			var viewport_pos = convert_click_to_viewport_coords(position)
			if viewport_pos == Vector2(-1, -1):  # Invalid position
				return
			
			# Clone the event and update its position
			new_event = event.duplicate()
			if new_event.has_method("set_position"):
				new_event.position = viewport_pos
			if new_event.has_method("set_global_position"):
				new_event.global_position = viewport_pos
		else:
			# No position provided, just duplicate the event
			new_event = event.duplicate()
	else:
		# For all other events (keyboard, gamepad, etc.) - just duplicate
		new_event = event.duplicate()
	
	# Send to viewport
	if new_event:
		print("Forwarding input to viewport: ", name, " event: ", new_event.get_class())
		viewport.push_input(new_event)


func _on_content_gui_input(event: InputEvent):
	"""Handle input events from content"""
	print("Content in panel ", name, " received input: ", event.get_class(), " - ", event.as_text())

func convert_click_to_viewport_coords(click_pos: Vector3) -> Vector2:
	"""Convert 3D click position to 2D viewport coordinates"""
	# Get local position relative to sprite
	var local_pos = sprite3d.to_local(click_pos)
	
	# Convert to UV coordinates (0-1 range)
	var world_size = get_world_size()
	var half_width = world_size.x / 2.0
	var half_height = world_size.y / 2.0
	
	# Check if click is within sprite bounds
	if abs(local_pos.x) > half_width or abs(local_pos.y) > half_height:
		return Vector2(-1, -1)  # Outside sprite
	
	# Convert to UV (0-1)
	var uv_x = (local_pos.x + half_width) / world_size.x
	var uv_y = 1.0 - (local_pos.y + half_height) / world_size.y  # Flip Y
	
	# Convert to viewport pixel coordinates
	var viewport_pos = Vector2(
		uv_x * viewport.size.x,
		uv_y * viewport.size.y
	)
	
	return viewport_pos

func set_content_scene(scene: PackedScene):
	"""Load a scene into this panel"""
	if not scene:
		return
	
	clear_content()
	
	content_instance = scene.instantiate()
	viewport.add_child(content_instance)
	
	# Ensure content can receive input if it's a Control node
	if content_instance is Control:
		setup_content_input_handling(content_instance)
	
	content_loaded.emit(self)
	content_changed.emit(self)

func set_content_node(node: Node):
	"""Add a node directly to this panel"""
	if not node:
		return
		
	clear_content()
	
	content_instance = node
	viewport.add_child(content_instance)
	
	# Ensure content can receive input if it's a Control node
	if content_instance is Control:
		setup_content_input_handling(content_instance)
	
	content_loaded.emit(self)
	content_changed.emit(self)

func setup_content_input_handling(control: Control):
	"""Setup input handling for Control nodes in the viewport"""
	# Ensure the control fills the viewport and can receive all input events
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	control.focus_mode = Control.FOCUS_ALL  # Enable focus for keyboard input
	
	# Connect to gui_input if possible
	if control.has_signal("gui_input") and not control.gui_input.is_connected(_on_content_gui_input):
		control.gui_input.connect(_on_content_gui_input)
	
	# Grab focus so it can receive keyboard input
	control.grab_focus()

func clear_content():
	"""Remove current content from panel"""
	if content_instance and is_instance_valid(content_instance):
		content_instance.queue_free()
		content_instance = null

func get_content() -> Node:
	"""Get current content node"""
	return content_instance

func get_panel_viewport() -> SubViewport:
	"""Get the panel's viewport for direct manipulation"""
	return viewport

func get_sprite3d() -> Sprite3D:
	"""Get the panel's sprite for camera targeting"""
	return sprite3d

func set_panel_size(size: Vector2i):
	"""Update panel resolution"""
	panel_size = size
	if viewport:
		viewport.size = size
		
	# Update collision shape to match new size
	if collision_shape and collision_shape.shape:
		var box_shape = collision_shape.shape as BoxShape3D
		if box_shape:
			var world_size = get_world_size()
			box_shape.size = Vector3(world_size.x, world_size.y, 0.1)

func set_panel_enabled(value: bool):
	"""Enable/disable panel rendering and input"""
	enabled = value
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED
	if sprite3d:
		sprite3d.visible = enabled
	if click_area:
		click_area.set_collision_layer_value(1, enabled)
		click_area.set_collision_mask_value(1, enabled)
	
	# Enable/disable input processing
	set_process_input(enabled)

func get_world_size() -> Vector2:
	"""Calculate panel size in world units"""
	var world_width = panel_size.x * pixel_size
	var world_height = panel_size.y * pixel_size
	var scale = sprite3d.scale if sprite3d else Vector3.ONE
	return Vector2(world_width * scale.x, world_height * scale.y)

func is_content_loaded() -> bool:
	"""Check if panel has content loaded"""
	return content_instance != null and is_instance_valid(content_instance)

## Convenience methods for common content types

func load_ui_scene(ui_scene_path: String):
	"""Load UI scene from path"""
	var scene = load(ui_scene_path) as PackedScene
	if scene:
		set_content_scene(scene)

func load_game_scene(game_scene_path: String):
	"""Load game scene from path"""
	var scene = load(game_scene_path) as PackedScene
	if scene:
		set_content_scene(scene)

func show_loading_screen():
	"""Show a simple loading indicator"""
	clear_content()
	
	var loading_label = Label.new()
	loading_label.text = "Loading..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.anchors_preset = Control.PRESET_FULL_RECT
	
	set_content_node(loading_label)

func show_error_message(message: String):
	"""Show error message in panel"""
	clear_content()
	
	var error_label = Label.new()
	error_label.text = "Error: " + message
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	error_label.anchors_preset = Control.PRESET_FULL_RECT
	error_label.modulate = Color.RED
	
	set_content_node(error_label)

## Panel-specific setup methods

func setup_as_gameplay_panel():
	"""Configure this panel for main gameplay"""
	# Higher update rate for gameplay
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func setup_as_ui_panel():
	"""Configure this panel for UI content"""
	# Standard update rate for UI
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func setup_as_map_panel():
	"""Configure this panel for map/stats display"""
	# Can use lower update rate if map is static
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
