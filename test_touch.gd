extends Control

# Configuration
var gesture_interval := 1
var min_swipe_distance := 100
var max_swipe_distance := 500

# State tracking
var timer := 0.0
var generating_gesture := false
var gesture_start_position := Vector2.ZERO
var gesture_direction := Vector2.ZERO

# Original code
const threshold := 5000
var pressedPos : Vector2
var releasePos : Vector2

func _ready() -> void:
	$Label.text = "Random gesture simulation running"

#func _process(delta: float) -> void:
	#timer += delta
	
	# Start a new random gesture
	#if timer >= gesture_interval and not generating_gesture:
	#	start_random_gesture()
	
	# Complete the gesture
	#elif generating_gesture:
	#	complete_gesture()

func start_random_gesture() -> void:
	generating_gesture = true
	
	# Choose a random screen position
	gesture_start_position = Vector2(
		randf_range(0, get_viewport_rect().size.x),
		randf_range(0, get_viewport_rect().size.y)
	)
	
	# Choose a random direction
	var angle := randf_range(0, TAU)  # Random angle in radians (0 to 2π)
	var distance := randf_range(min_swipe_distance, max_swipe_distance)
	gesture_direction = Vector2(cos(angle), sin(angle)) * distance
	
	# Create and dispatch touch press event
	var touch_press := InputEventScreenTouch.new()
	touch_press.pressed = true
	touch_press.position = gesture_start_position
	touch_press.index = 0
	Input.parse_input_event(touch_press)
	
	# Store for the gesture calculation
	pressedPos = gesture_start_position
	
	# Update label
	$Label.text = "Gesture started at " + str(gesture_start_position)

func complete_gesture() -> void:
	# Calculate end position
	var end_position := gesture_start_position + gesture_direction
	
	# Create drag event
	var drag := InputEventScreenDrag.new()
	drag.position = end_position
	drag.relative = gesture_direction
	drag.index = 0
	Input.parse_input_event(drag)
	
	# Create touch release event
	var touch_release := InputEventScreenTouch.new()
	touch_release.pressed = false
	touch_release.position = end_position
	touch_release.index = 0
	Input.parse_input_event(touch_release)
	
	# Store for the gesture calculation
	releasePos = end_position
	
	# Reset state
	generating_gesture = false
	timer = 0.0
	
	# Update label
	$Label.text = "Gesture ended at " + str(end_position)

func _input(event: InputEvent) -> void:
	if event.is_action("ui_left"):
		$TextureRect.flip_h = true
	elif event.is_action("ui_right"):
		$TextureRect.flip_h = false

	if event.is_action("ui_up"):
		$TextureRect.flip_v = true
	elif event.is_action("ui_down"):
		$TextureRect.flip_v = false
