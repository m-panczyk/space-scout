# Gesture-only touch_controls.gd
extends Control

class_name GestureControls

signal gesture_detected(gesture_type: String, direction: Vector2)

# Gesture detection settings
@export var enable_panel_gestures = true
@export var swipe_threshold: float = 100.0
@export var swipe_max_time: float = 0.8

# Reference to ThreeWayDisplay for panel navigation
var three_way_display: ThreeWayDisplay

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Find ThreeWayDisplay parent
	three_way_display = get_parent()
	if not three_way_display is ThreeWayDisplay:
		# Search up the tree
		var current = get_parent()
		while current and not current is ThreeWayDisplay:
			current = current.get_parent()
		three_way_display = current

func _input(event: InputEvent) -> void:
	# Handle panel gestures
	if event is InputEventGesture and enable_panel_gestures:
		handle_gesture_event(event)

func handle_gesture_event(event: InputEventGesture):
	"""Handle gesture events for panel navigation"""
	if event is InputEventPanGesture:
		handle_pan_gesture(event)

func handle_pan_gesture(event: InputEventPanGesture):
	"""Handle pan gesture for panel navigation"""
	if not three_way_display:
		return
	
	# Don't handle gestures if camera is transitioning
	if three_way_display.camera and three_way_display.camera.is_camera_transitioning():
		return
	
	var pan_delta = event.delta
	
	# Only handle significant horizontal pans
	if abs(pan_delta.x) > abs(pan_delta.y) and abs(pan_delta.x) > 10.0:
		if pan_delta.x > 0:
			# Pan right -> move to left panel
			three_way_display.switch_to_left_panel()
			gesture_detected.emit("swipe_right", Vector2.RIGHT)
		else:
			# Pan left -> move to right panel
			three_way_display.switch_to_right_panel()
			gesture_detected.emit("swipe_left", Vector2.LEFT)

# Configuration methods
func set_panel_gestures_enabled(enabled: bool) -> void:
	enable_panel_gestures = enabled

func set_swipe_settings(threshold: float, max_time: float) -> void:
	swipe_threshold = threshold
	swipe_max_time = max_time
