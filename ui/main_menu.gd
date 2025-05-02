extends Control

var title = ''

var game_scene = preload("res://game.tscn")
var settings = preload("res://ui/settings.tscn")

func _on_start_game(player_config, level_config):
	$Lobby.hide_lobby()
	var new_level = $Lobby.create_game_level()
	add_child(new_level)

func new_game() -> void:
	get_tree().change_scene_to_packed(game_scene)

func continue_game() -> void:
	game_scene.load_game(0)
	get_tree().change_scene_to_packed(game_scene)

	


func _on_exit_button_down() -> void:
	get_tree().quit()


func _on_settings_button_down() -> void:
	get_parent().replace_current_scene(settings)
