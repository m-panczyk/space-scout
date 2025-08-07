class_name ThreeWayCamera3D
extends Camera3D

## Simplified camera for ThreeWayDisplay system
## Only adjusts rotation and zoom, keeps position fixed

signal panel_changed(panel_index: int)
signal transition_complete
signal transition_started

@export_group("Camera Settings")
@export var transition_duration: float = 1.0
@export var padding_ratio: float = 0.08
@export var min_distance: float = 6.0
@export var max_distance: float = 25.0
@export var auto_adjust_on_resize: bool = true

var panels: Array[Sprite3D] = []
var current_panel_index: int = 1  # Start with center panel
var fixed_position: Vector3
var is_transitioning: bool = false
var resize_timer: Timer
var current_tween: Tween

func _ready():
	fixed_position = global_position
	setup_resize_timer()

func setup_resize_timer():
	resize_timer = Timer.new()
	resize_timer.wait_time = 0.2
	resize_timer.one_shot = true
	resize_timer.timeout.connect(_on_resize_timeout)
	add_child(resize_timer)

func initialize_with_panels(sprite_panels: Array):
	"""Initialize camera with the three panel sprites"""
	# Convert to typed array for internal use
	panels.clear()
	for sprite in sprite_panels:
		if sprite is Sprite3D:
			panels.append(sprite)
		else:
			push_error("ThreeWayCamera3D: initialize_with_panels requires Array of Sprite3D nodes")
			return
	
	# Set up initial view for center panel
	if panels.size() > 1:
		global_position = fixed_position
		frame_panel_instant(panels[1])

func switch_to_panel_index(index: int, animate: bool = true):
	"""Switch to specific panel by index"""
	if index < 0 or index >= panels.size() or index == current_panel_index:
		return
	
	current_panel_index = index
	var target_panel = panels[index]
	
	if animate and transition_duration > 0:
		transition_started.emit()
		animate_to_panel(target_panel)
	else:
		frame_panel_instant(target_panel)
	
	panel_changed.emit(current_panel_index)

func switch_to_panel_to_the_right():
	"""Switch to panel to the right (left->center->right, stop at right)"""
	if current_panel_index < panels.size() - 1:
		switch_to_panel_index(current_panel_index + 1)

func switch_to_panel_to_the_left():
	"""Switch to panel to the left (right->center->left, stop at left)"""
	if current_panel_index > 0:
		switch_to_panel_index(current_panel_index - 1)

func animate_to_panel(target_panel: Sprite3D):
	"""Smooth animated transition to target panel - rotation and zoom only"""
	is_transitioning = true
	
	# Kill existing tween if any
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_parallel(true)
	
	# Calculate target rotation to look at panel
	var direction_to_panel = (target_panel.global_position - fixed_position).normalized()
	var target_basis = Basis.looking_at(direction_to_panel, Vector3.UP)
	
	# Animate rotation
	current_tween.tween_method(
		func(basis: Basis): global_transform.basis = basis,
		global_transform.basis,
		target_basis,
		transition_duration
	)
	
	# Calculate and animate FOV for optimal framing
	var optimal_fov = calculate_optimal_fov(target_panel)
	current_tween.tween_property(self, "fov", optimal_fov, transition_duration)
	
	current_tween.finished.connect(func():
		is_transitioning = false
		current_tween = null
		transition_complete.emit()
	)

func make_transition_instant():
	"""Make current transition instant"""
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		current_tween = null
		
		# Jump to final panel position
		if current_panel_index >= 0 and current_panel_index < panels.size():
			frame_panel_instant(panels[current_panel_index])
		
		is_transitioning = false
		transition_complete.emit()

func frame_panel_instant(target_panel: Sprite3D):
	"""Instantly frame target panel - rotation and zoom only"""
	# Point camera at panel
	var direction_to_panel = (target_panel.global_position - fixed_position).normalized()
	global_transform.basis = Basis.looking_at(direction_to_panel, Vector3.UP)
	
	# Adjust FOV for optimal framing
	fov = calculate_optimal_fov(target_panel)

func calculate_optimal_fov(panel_sprite: Sprite3D) -> float:
	"""Calculate optimal FOV to frame the panel properly"""
	var panel_node = panel_sprite.get_parent() as ThreeWayPanel
	if not panel_node:
		return 75.0  # Default FOV
	
	var panel_size = panel_node.get_world_size()
	var distance_to_panel = fixed_position.distance_to(panel_sprite.global_position)
	var viewport_size = get_viewport().get_visible_rect().size
	var aspect_ratio = viewport_size.x / viewport_size.y
	
	# Determine constraining dimension
	var max_dimension: float
	if panel_size.x / panel_size.y > aspect_ratio:
		max_dimension = panel_size.x / aspect_ratio
	else:
		max_dimension = panel_size.y
	
	# Add padding
	max_dimension *= (1.0 + padding_ratio)
	
	# Calculate required FOV
	var half_height = max_dimension / 2.0
	var required_fov_rad = 2.0 * atan(half_height / distance_to_panel)
	var required_fov_deg = rad_to_deg(required_fov_rad)
	
	# Clamp FOV to reasonable range
	return clamp(required_fov_deg, 30.0, 120.0)

func get_current_panel_sprite() -> Sprite3D:
	"""Get currently targeted panel sprite"""
	if current_panel_index >= 0 and current_panel_index < panels.size():
		return panels[current_panel_index]
	return null

func is_panel_fully_visible(panel_sprite: Sprite3D) -> bool:
	"""Check if panel is fully visible in camera view"""
	var panel_node = panel_sprite.get_parent() as ThreeWayPanel
	if not panel_node:
		return false
	
	var panel_size = panel_node.get_world_size()
	var panel_pos = panel_sprite.global_position
	var panel_transform = panel_sprite.global_transform
	
	# Get the four corners of the panel
	var half_width = panel_size.x / 2.0
	var half_height = panel_size.y / 2.0
	
	var corners = [
		panel_pos + panel_transform.basis.x * -half_width + panel_transform.basis.y * half_height,
		panel_pos + panel_transform.basis.x * half_width + panel_transform.basis.y * half_height,
		panel_pos + panel_transform.basis.x * half_width + panel_transform.basis.y * -half_height,
		panel_pos + panel_transform.basis.x * -half_width + panel_transform.basis.y * -half_height
	]
	
	# Check if all corners are visible
	for corner in corners:
		if not is_position_in_view(corner):
			return false
	
	return true

func is_position_in_view(world_pos: Vector3) -> bool:
	"""Check if world position is visible in camera"""
	var local_pos = to_local(world_pos)
	if local_pos.z > 0:  # Behind camera
		return false
	
	var screen_pos = unproject_position(world_pos)
	var viewport_rect = get_viewport().get_visible_rect()
	
	return (screen_pos.x >= 0 and screen_pos.x <= viewport_rect.size.x and
			screen_pos.y >= 0 and screen_pos.y <= viewport_rect.size.y)

func handle_viewport_resize():
	"""Handle viewport size changes"""
	if auto_adjust_on_resize:
		resize_timer.start()

func _on_resize_timeout():
	"""Readjust camera after viewport resize"""
	if current_panel_index >= 0 and current_panel_index < panels.size():
		var current_panel = panels[current_panel_index]
		frame_panel_instant(current_panel)

func is_camera_transitioning() -> bool:
	"""Check if camera is currently transitioning"""
	return is_transitioning

## Debug and utility methods

func get_current_panel_index() -> int:
	"""Get index of currently selected panel"""
	return current_panel_index

func reset_to_original_position():
	"""Reset camera to fixed position and reframe current panel"""
	global_position = fixed_position
	fov = 75.0  # Reset to default FOV
	
	await get_tree().process_frame
	
	if current_panel_index >= 0 and current_panel_index < panels.size():
		frame_panel_instant(panels[current_panel_index])
