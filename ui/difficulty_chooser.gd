extends Control
var title = "Nowa Gra"
func _on_easy_pressed() -> void:
	SaveData.difficulty_level = 0 
	get_tree().change_scene_to_packed(load("res://game.tscn"))

func _on_normal_pressed() -> void:
	SaveData.difficulty_level = 1
	get_tree().change_scene_to_packed(load("res://game.tscn"))


func _on_hard_pressed() -> void:
	SaveData.difficulty_level = 2
	get_tree().change_scene_to_packed(load("res://game.tscn"))
