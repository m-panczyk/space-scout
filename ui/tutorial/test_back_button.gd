extends Button
class_name KillButton

@export var victim:Control

func _pressed() -> void:
	victim.queue_free()
