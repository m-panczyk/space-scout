extends Control

class_name TouchControls

@export var touch_controls_type := GlobalSettings.TouchControlType.JOYPAD_TOUCH
var touch_controls

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if touch_controls_type == GlobalSettings.TouchControlType.JOYPAD_TOUCH:
		touch_controls = TouchScreenJoystick.new()
		touch_controls.use_input_actions = true
		touch_controls.mode = 1
		touch_controls.change_opacity_when_touched = true
		touch_controls.from_opacity = 0.0
		touch_controls.knob_scale = 0.5
		touch_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(touch_controls)
	else:
		print_debug("Touch controls not defined")
