extends Control

@export var ok_button:Button
@export var back_button:Button
@export var presentation: Array[Control]
var pres_index:int = 0

func _ready() -> void:
	for i in range(1,presentation.size()):
		presentation[i].hide()
	ok_button.pressed.connect(func(): change_slide(1))
	back_button.pressed.connect(func(): change_slide(-1))
	ok_button.grab_focus()
	
func change_slide(change:int):
	presentation[pres_index].hide()
	pres_index += change
	if pres_index >= presentation.size():
		get_tree().change_scene_to_file("res://Game.tscn")
		return
	presentation[pres_index].show()
	if pres_index == 0:
		back_button.hide()
	else:
		back_button.show()


func _on_visibility_changed() -> void:
	if visible:
		ok_button.grab_focus()
