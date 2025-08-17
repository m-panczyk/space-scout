extends Button

@export var option:String
@export var label:Label

func _ready() -> void:
	if option.is_empty():
		option = text
	connect("pressed",_on_pressed)
	
func _on_pressed() -> void:
	label.text = option
