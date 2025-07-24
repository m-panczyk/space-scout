class_name ThreeWayCamera3D
extends Camera3D

## Specialized camera for ThreeWayDisplay system
## Handles smooth transitions between exactly 3 panels

signal panel_changed(panel_index: int)
signal transition_complete

@export_group("Camera Settings")
@export var transition_duration: float = 1.0
@export var padding_ratio: float = 0.08
@export var min_distance: float = 6.0
@export var max_distance: float = 25.0
@export var auto_adjust_on_resize: bool = true

var panels: Array[Sprite3D] = []
var current_panel_index: int = 1  # Start with center panel
var original_position: Vector3
var is_transitioning: bool = false
var resize_timer: Timer

func _ready():
	original_position = global_position
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
	# Position camera to view center panel initially
	if panels.size() > 1:
		global_position = original_position
		look_at(panels[1].global_position, Vector3.UP)
		adjust_distance_for_current_panel()

func switch_to_panel_index(index: int, animate: bool = true):
	"""Switch to specific panel by index"""
	if index < 0 or index >= panels.size() or index == current_panel_index:
		return
	
	current_panel_index = index
	var target_panel = panels[index]
	
	if animate and transition_duration > 0:
		animate_to_panel(target_panel)
	else:
		frame_panel_instant(target_panel)
	
	panel_changed.emit(current_panel_index)

func switch_to_next_panel():
	"""Switch to next panel (0->1->2->0)"""
	var next_index = (current_panel_index + 1) % panels.size()
	switch_to_panel_index(next_index)

func switch_to_previous_panel():
	"""Switch to previous panel (2->1->0->2)"""
	var prev_index = (current_panel_index - 1) % panels.size()
	if prev_index < 0:
		prev_index = panels.size() - 1
	switch_to_panel_index(prev_index)

func animate_to_panel(target_panel: Sprite3D):
	"""Smooth animated transition to target panel"""
	is_transitioning = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Step 1: Rotate around pivot point to face panel
	var pivot = original_position
	var current_pos = global_position
	var target_look_direction = (target_panel.global_position - pivot).normalized()
	var distance_from_pivot = current_pos.distance_to(pivot)
	var target_pos_after_rotation = pivot + target_look_direction * distance_from_pivot
	
	# Animate position (creates rotation around pivot effect)
	tween.tween_property(self, "global_position", target_pos_after_rotation, transition_duration * 0.5)
	
	# Animate rotation to look at panel
	var current_basis = global_transform.basis
	var target_basis = Basis.looking_at(target_look_direction, Vector3.UP)
	tween.tween_method(
		func(basis: Basis): global_transform.basis = basis,
		current_basis,
		target_basis,
		transition_duration * 0.5
	)
	
	# Step 2: After rotation, adjust distance for optimal framing
	tween.tween_callback(func(): adjust_distance_animated(target_panel))

func adjust_distance_animated(target_panel: Sprite3D):
	"""Animate distance adjustment for optimal panel framing"""
	var optimal_distance = calculate_optimal_distance(target_panel)
	var direction = (target_panel.global_position - global_position).normalized()
	var target_position = target_panel.global_position - direction * optimal_distance
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, transition_duration * 0.5)
	tween.finished.connect(func():
		is_transitioning = false
		transition_complete.emit()
	)

func frame_panel_instant(target_panel: Sprite3D):
	"""Instantly position camera for target panel"""
	# Rotate around pivot to face panel
	var pivot = original_position
	var current_pos = global_position
	var target_look_direction = (target_panel.global_position - pivot).normalized()
	var distance_from_pivot = current_pos.distance_to(pivot)
	
	global_position = pivot + target_look_direction * distance_from_pivot
	look_at(target_panel.global_position, Vector3.UP)
	
	# Adjust distance for optimal framing
	adjust_distance_for_panel(target_panel)

func calculate_optimal_distance(panel_sprite: Sprite3D) -> float:
	"""Calculate optimal camera distance for panel"""
	var panel_node = panel_sprite.get_parent() as ThreeWayPanel
	if not panel_node:
		return min_distance
	
	var panel_size = panel_node.get_world_size()
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
	
	# Calculate distance using FOV
	var half_fov_rad = deg_to_rad(fov / 2.0)
	var required_distance = (max_dimension / 2.0) / tan(half_fov_rad)
	
	return clamp(required_distance, min_distance, max_distance)

func adjust_distance_for_panel(panel_sprite: Sprite3D):
	"""Adjust camera distance for optimal panel framing"""
	var optimal_distance = calculate_optimal_distance(panel_sprite)
	var direction = (panel_sprite.global_position - global_position).normalized()
	global_position = panel_sprite.global_position - direction * optimal_distance

func adjust_distance_for_current_panel():
	"""Adjust distance for currently selected panel"""
	if current_panel_index >= 0 and current_panel_index < panels.size():
		adjust_distance_for_panel(panels[current_panel_index])

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
		look_at(current_panel.global_position, Vector3.UP)
		adjust_distance_for_panel(current_panel)

func is_camera_transitioning() -> bool:
	"""Check if camera is currently transitioning"""
	return is_transitioning

## Debug and utility methods

func get_current_panel_index() -> int:
	"""Get index of currently selected panel"""
	return current_panel_index

func reset_to_original_position():
	"""Reset camera to original position and reframe current panel"""
	global_position = original_position
	rotation = Vector3.ZERO
	
	await get_tree().process_frame
	
	if current_panel_index >= 0 and current_panel_index < panels.size():
		frame_panel_instant(panels[current_panel_index])
