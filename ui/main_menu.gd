extends VBoxContainer

var title = ''

var game_scene = "res://game.tscn"
var settings = preload("res://ui/settings.tscn")

func pause_menu():
	$SaveGame.show()
	$ContinueGame.hide()

func new_game() -> void:
	get_tree().change_scene_to_packed(load(game_scene))

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	get_parent().get_parent().replace_current_scene(settings)
