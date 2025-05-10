extends Button

@export var action = "ui_cancel"
var action_event

func _ready() -> void:
	action_event = InputEventAction.new()
	action_event.action = action
	visible = DisplayServer.is_touchscreen_available()

func _on_button_down() -> void:
	action_event.pressed = true
	Input.parse_input_event(action_event)

func _on_button_up() -> void:
	action_event.pressed = false
	Input.parse_input_event(action_event)
