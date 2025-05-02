extends VBoxContainer

var title = ''

var game_scene = preload("res://game.tscn")
var settings = preload("res://ui/settings.tscn")

func new_game() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_exit_button_down() -> void:
	get_tree().quit()


func _on_settings_button_down() -> void:
	get_parent().replace_current_scene(settings)
