extends Button

func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		show()

func _on_pressed() -> void:
	Input.action_release("ui_cancel")
