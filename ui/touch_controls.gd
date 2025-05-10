extends Control

class_name TouchControls

@export var touch_controls_type = GlobalSettings.touch_controls
var touch_controls
var player
signal touched(touch:InputEventScreenTouch)
var active_touches = {}

# Double tap detection variables
var last_tap_time = 0
var last_tap_position = Vector2.ZERO
var double_tap_timeout = 0.3  # Maximum time between taps (in seconds)
var double_tap_distance = 50  # Maximum distance between taps (in pixels)
@export var enable_double_tap = true

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	player = get_tree().get_nodes_in_group("PLAYER")[0]
	if touch_controls_type == GlobalSettings.TouchControlType.JOYPAD_TOUCH:
		touch_controls = TouchScreenJoystick.new()
		touch_controls.use_input_actions = true
		touch_controls.mode = 1
		touch_controls.change_opacity_when_touched = true
		touch_controls.from_opacity = 0.0
		touch_controls.knob_scale = 0.5
		touch_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(touch_controls)
	if touch_controls_type == GlobalSettings.TouchControlType.POINT:
		connect("touched", _on_touch_control)
	else:
		print_debug("Touch controls not defined")
	
func _input(event:InputEvent) -> void:
	if event is InputEventScreenTouch:
		# Handle double tap detection (works for both control types)
		var touch = event as InputEventScreenTouch
		if touch.pressed:
			var current_time = Time.get_ticks_msec() / 1000.0
			var current_position = touch.position
			
			# Check if this could be a double tap
			if enable_double_tap and current_time - last_tap_time < double_tap_timeout and current_position.distance_to(last_tap_position) < double_tap_distance:
				player.fire_weapon()
				# Double tap detected!
				print("Double tap detected!")

			
			# Store this tap's info for potential future double tap detection
			last_tap_time = current_time
			last_tap_position = current_position
		
		touched.emit(event)

# Variable to store the target position
var target_position = null

func _on_touch_control(touch: InputEventScreenTouch):
	if touch.pressed:
		# Store the touch position as the target position
		target_position = touch.position
		
		# Calculate direction vector from player to touch position
		var direction = (target_position - player.position).normalized()
		
		# Set velocity or movement direction based on your player's movement system
		# Option 1: If your player uses input actions for movement
		if direction.x > 0.1:
			Input.action_press("ui_right")
			Input.action_release("ui_left")
		elif direction.x < -0.1:
			Input.action_press("ui_left")
			Input.action_release("ui_right")
		else:
			Input.action_release("ui_right")
			Input.action_release("ui_left")
			
		if direction.y > 0.1:
			Input.action_press("ui_down")
			Input.action_release("ui_up")
		elif direction.y < -0.1:
			Input.action_press("ui_up")
			Input.action_release("ui_down")
		else:
			Input.action_release("ui_up")
			Input.action_release("ui_down")
		
		# Store target position on player for reference
		player.set_meta("target_position", target_position)
		
		print("New target position set: ", target_position)
		# Add new touch point to dictionary
		active_touches[touch.index] = touch.position
	elif touch.is_released():
		if active_touches.has(touch.index):
			active_touches.erase(touch.index)
		if active_touches.size() == 0:
			target_position = null
			Input.action_release("ui_up")
			Input.action_release("ui_down")
			Input.action_release("ui_right")
			Input.action_release("ui_left")

func _process(_delta):
	if target_position != null and player != null:
		# Calculate current direction to target
		var direction = (target_position - player.position).normalized()
		var distance = player.position.distance_to(target_position)
		
		# If player is close enough to target, stop movement
		if distance < 10:  # Adjust this threshold as needed
			Input.action_release("ui_right")
			Input.action_release("ui_left")
			Input.action_release("ui_up")
			Input.action_release("ui_down")
			target_position = null
			print("Target reached, movement stopped")
			return
			
		# Update movement direction based on current position
		if direction.x > 0.1:
			Input.action_press("ui_right")
			Input.action_release("ui_left")
		elif direction.x < -0.1:
			Input.action_press("ui_left")
			Input.action_release("ui_right")
		else:
			Input.action_release("ui_right")
			Input.action_release("ui_left")
			
		if direction.y > 0.1:
			Input.action_press("ui_down")
			Input.action_release("ui_up")
		elif direction.y < -0.1:
			Input.action_press("ui_up")
			Input.action_release("ui_down")
		else:
			Input.action_release("ui_up")
			Input.action_release("ui_down")

# Helper functions to configure double tap detection
func set_double_tap_timeout(timeout_seconds: float) -> void:
	double_tap_timeout = timeout_seconds

func set_double_tap_distance(distance_pixels: float) -> void:
	double_tap_distance = distance_pixels
