extends VBoxContainer

var title = ''

var settings = preload("res://ui/menu/settings.tscn")
var load_game = preload("res://ui/menu/load_game.tscn")
var save_game = preload("res://ui/menu/save_game.tscn")

func _ready() -> void:
	if SaveData.get_all_save_files():
		$ContinueGame.disabled = false
	EventBus.subscribe('end_lvl',end_lvl)
	EventBus.subscribe('start_lvl',prepare_lvl)
func _exit_tree() -> void:
	EventBus.unsubscribe('end_lvl',end_lvl)
	EventBus.unsubscribe('start_lvl',prepare_lvl)
func end_lvl(_success:bool):
	$SaveGame.disabled = false
func prepare_lvl(_punished:bool):
	$SaveGame.disabled = true

func pause_menu():
	$SaveGame.show()
	$ContinueGame.hide()

func new_game() -> void:
	get_parent().get_parent().replace_current_scene(load("res://ui/DifficultyChooser.tscn"))

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	get_parent().get_parent().replace_current_scene(settings)


func _on_save_game_pressed() -> void:
	#SaveData.show_save_dialog()
	get_parent().get_parent().replace_current_scene(save_game)


func _on_continue_game_pressed() -> void:
	SaveData.load_latest_save()
	get_tree().change_scene_to_packed(load("res://game.tscn"))


func _on_load_game_pressed() -> void:
	get_parent().get_parent().replace_current_scene(load_game)
