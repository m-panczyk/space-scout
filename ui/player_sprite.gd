extends TextureRect

# Export variables for customization in the editor
@export var rotation_speed: float = 100.0
@export var max_rotation: float = 30.0  # Rotation limit in degrees
@export var return_speed: float = 5.0   # Speed of return to original position

# Internal variables to track touch state
var last_touch_position: Vector2
var is_dragging: bool = false

func _process(delta):
	# Only apply automatic return when not dragging
	if not is_dragging:
		var current_y_rot = material.get_shader_parameter("y_rot")
		var current_x_rot = material.get_shader_parameter("x_rot")
		
		# Smooth interpolation back to 0 (original position)
		var new_y_rot = lerp(current_y_rot, 0.0, return_speed * delta)
		var new_x_rot = lerp(current_x_rot, 0.0, return_speed * delta)
		
		# Apply the new rotation values to shader parameters
		material.set_shader_parameter("y_rot", new_y_rot)
		material.set_shader_parameter("x_rot", new_x_rot)

func _input(event):
	# Handle screen drag events for rotation control
	if event is InputEventScreenDrag:
		is_dragging = true
		
		# Calculate movement delta from last position
		var delta_x = event.position.x - last_touch_position.x
		var delta_y = event.position.y - last_touch_position.y
		
		# Get center points for determining which half of the screen
		var half_width = size.x * 0.5
		var half_height = size.y * 0.5
		
		# Get current rotation values
		var current_y_rot = material.get_shader_parameter("y_rot")
		var current_x_rot = material.get_shader_parameter("x_rot")
		var new_y_rot = current_y_rot
		var new_x_rot = current_x_rot
		
		# Y-axis rotation based on horizontal position
		if event.position.x > half_width:
			# Right half → Negative Y rotation
			new_y_rot -= delta_x * rotation_speed * 0.01
		else:
			# Left half → Positive Y rotation
			new_y_rot += delta_x * rotation_speed * 0.01
		
		# X-axis rotation based on vertical position
		if event.position.y > half_height:
			# Bottom half → Positive X rotation
			new_x_rot += delta_y * rotation_speed * 0.01
		else:
			# Top half → Negative X rotation
			new_x_rot -= delta_y * rotation_speed * 0.01
		
		# Clamp rotation values to stay within limits
		new_y_rot = clamp(new_y_rot, -max_rotation, max_rotation)
		new_x_rot = clamp(new_x_rot, -max_rotation, max_rotation)
		
		# Apply the calculated rotation to shader parameters
		material.set_shader_parameter("y_rot", new_y_rot)
		material.set_shader_parameter("x_rot", new_x_rot)
		
		# Update last touch position for next frame
		last_touch_position = event.position
	
	# Handle touch press/release events
	elif event is InputEventScreenTouch:
		if event.pressed:
			# Touch started - record initial position
			last_touch_position = event.position
		else:
			# Touch ended - enable automatic return to center
			is_dragging = false
