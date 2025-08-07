# Gesture-only touch_controls.gd
extends Control

class_name GestureControlsololo

signal gesture_detected(gesture_type: String, direction: Vector2)
signal pause_requested()  # New signal for pause requests

# Gesture detection settings
@export var enable_panel_gestures = true
@export var enable_pause_gestures = true  # New setting for pause gestures
@export var swipe_threshold: float = 100.0
@export var swipe_max_time: float = 0.8
@export var pause_pan_threshold: float = 150.0  # Threshold for down pan to trigger pause

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
	# Handle Android back button
	if event.is_action_pressed("ui_cancel") and enable_pause_gestures:
		handle_pause_request()
		get_viewport().set_input_as_handled()
		return
	
	# Handle panel gestures
	if event is InputEventGesture and enable_panel_gestures:
		handle_gesture_event(event)

func _notification(what):
	# Handle Android back button through notification system
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and enable_pause_gestures:
		handle_pause_request()

func handle_gesture_event(event: InputEventGesture):
	"""Handle gesture events for panel navigation and pause"""
	if event is InputEventPanGesture:
		handle_pan_gesture(event)

func handle_pan_gesture(event: InputEventPanGesture):
	"""Handle pan gesture for panel navigation and pause functionality"""
	var pan_delta = event.delta
	
	# Check for down pan gesture to pause (only if pause gestures enabled)
	if enable_pause_gestures and pan_delta.y > pause_pan_threshold and abs(pan_delta.y) > abs(pan_delta.x):
		handle_pause_request()
		gesture_detected.emit("swipe_down", Vector2.DOWN)
		return
	
	# Handle horizontal panel navigation
	if not three_way_display or not enable_panel_gestures:
		return
	
	# Don't handle panel gestures if camera is transitioning
	if three_way_display.camera and three_way_display.camera.is_camera_transitioning():
		return
	
	# Only handle significant horizontal pans
	if abs(pan_delta.x) > abs(pan_delta.y) and abs(pan_delta.x) > 10.0:
		if pan_delta.x > 0:
			# Pan right -> move to left panel
			three_way_display.switch_to_panel_to_the_left()
			gesture_detected.emit("swipe_right", Vector2.RIGHT)
		else:
			# Pan left -> move to right panel
			three_way_display.switch_to_panel_to_the_right()
			gesture_detected.emit("swipe_left", Vector2.LEFT)

func handle_pause_request():
	"""Handle pause request from gestures or back button"""
	pause_requested.emit()

# Configuration methods
func set_panel_gestures_enabled(enabled: bool) -> void:
	enable_panel_gestures = enabled

func set_pause_gestures_enabled(enabled: bool) -> void:
	enable_pause_gestures = enabled

func set_swipe_settings(threshold: float, max_time: float) -> void:
	swipe_threshold = threshold
	swipe_max_time = max_time

func set_pause_pan_threshold(threshold: float) -> void:
	pause_pan_threshold = threshold
