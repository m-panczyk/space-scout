# Fixed three_way_panel.gd
class_name ThreeWayPanel
extends Node3D

## Individual panel component for ThreeWayDisplay system
## Manages a Sprite3D with SubViewport content

signal content_loaded(panel: ThreeWayPanel)
signal content_changed(panel: ThreeWayPanel)
signal panel_touched(panel: ThreeWayPanel)

@export var panel_size: Vector2i = Vector2i(1080, 1920) : set = set_panel_size
@export var pixel_size: float = 0.01
@export var enabled: bool = true : set = set_panel_enabled

var sprite3d: Sprite3D
var viewport: SubViewport
var content_instance: Node
var viewport_texture: ViewportTexture
var click_area: Area3D
var collision_shape: CollisionShape3D

# Reference to the camera for checking visibility
var camera_ref: ThreeWayCamera3D

func _ready():
	find_components()
	setup_click_detection()
	find_camera_reference()

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
	viewport = get_node_or_null("PanelViewport")
	if not viewport:
		push_error("ThreeWayPanel (" + name + "): Missing PanelViewport child node")
		return
	
	# Find Sprite3D
	sprite3d = get_node_or_null("PanelSprite")
	if not sprite3d:
		push_error("ThreeWayPanel (" + name + "): Missing PanelSprite child node")
		return
	
	# Get viewport texture
	viewport_texture = viewport.get_texture()
	
	# Set initial properties
	viewport.size = panel_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sprite3d.pixel_size = pixel_size
	sprite3d.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	
	# Viewport doesn't have gui_input signal - input handling is done through Area3D

func setup_click_detection():
	"""Set up Area3D for click detection"""
	click_area = Area3D.new()
	click_area.name = "ClickArea"
	add_child(click_area)
	
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "ClickShape"
	click_area.add_child(collision_shape)
	
	# Create box shape matching sprite size
	var box_shape = BoxShape3D.new()
	var world_size = get_world_size()
	box_shape.size = Vector3(world_size.x, world_size.y, 0.1)
	collision_shape.shape = box_shape
	
	# Connect click signal
	click_area.input_event.connect(_on_area_input_event)

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle touch/click events on the panel"""
	if not enabled:
		return
	
	if not event is InputEventMouseButton and not event is InputEventScreenTouch:
		return
	
	# Handle touch events
	if event is InputEventScreenTouch:
		handle_touch_event(event, position)
		return
	
	# Handle mouse events
	if event is InputEventMouseButton:
		handle_mouse_event(event, position)
		return

func handle_touch_event(event: InputEventScreenTouch, position: Vector3):
	"""Handle touch-specific events"""
	if not event.pressed:
		return
	
	# On touch devices, if panel is not fully visible, focus on it instead of forwarding touch
	if not is_panel_fully_visible():
		panel_touched.emit(self)
		return
	
	# Panel is fully visible, forward touch to viewport content
	forward_input_to_viewport(event, position)

func handle_mouse_event(event: InputEventMouseButton, position: Vector3):
	"""Handle mouse-specific events"""
	if not event.pressed:
		return
	
	# Right-click: focus on panel if not fully visible (like touch behavior)
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if not is_panel_fully_visible():
			panel_touched.emit(self)
			return
		# If panel is fully visible, forward right-click to content
		forward_input_to_viewport(event, position)
		return
	
	# Left-click: always forward to viewport content (normal interaction)
	if event.button_index == MOUSE_BUTTON_LEFT:
		forward_input_to_viewport(event, position)
		return

func is_panel_fully_visible() -> bool:
	"""Check if this panel is fully visible in the camera view"""
	if not camera_ref:
		find_camera_reference()
		if not camera_ref:
			return true  # Assume visible if can't find camera
	
	return camera_ref.is_panel_fully_visible(sprite3d)

func forward_input_to_viewport(event: InputEvent, position: Vector3):
	"""Forward the input event to the viewport content"""
	# Convert 3D click position to 2D viewport coordinates
	var viewport_pos = convert_click_to_viewport_coords(position)
	if viewport_pos == Vector2(-1, -1):  # Invalid position
		return
	
	# Create new event with converted coordinates
	var new_event: InputEvent
	if event is InputEventMouseButton:
		var mouse_event = InputEventMouseButton.new()
		mouse_event.button_index = event.button_index
		mouse_event.pressed = event.pressed
		mouse_event.position = viewport_pos
		mouse_event.global_position = viewport_pos
		new_event = mouse_event
	elif event is InputEventScreenTouch:
		var touch_event = InputEventScreenTouch.new()
		touch_event.index = event.index
		touch_event.pressed = event.pressed
		touch_event.position = viewport_pos
		new_event = touch_event
	
	# Send to viewport - use both methods to ensure delivery
	if new_event:
		print("Forwarding input to viewport: ", name, " at position: ", viewport_pos)
		viewport.push_input(new_event)
		
		# Also try using _gui_input directly on viewport content
		if viewport.get_child_count() > 0:
			var first_child = viewport.get_child(0)
			if first_child is Control and first_child.has_method("_gui_input"):
				first_child._gui_input(new_event)

func _on_content_gui_input(event: InputEvent):
	"""Handle input events from content"""
	print("Content in panel ", name, " received input: ", event)

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
	# Ensure the control fills the viewport and can receive mouse events
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connect to gui_input if possible
	if control.has_signal("gui_input") and not control.gui_input.is_connected(_on_content_gui_input):
		control.gui_input.connect(_on_content_gui_input)

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
	"""Enable/disable panel rendering"""
	enabled = value
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED
	if sprite3d:
		sprite3d.visible = enabled
	if click_area:
		click_area.set_collision_layer_value(1, enabled)
		click_area.set_collision_mask_value(1, enabled)

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
