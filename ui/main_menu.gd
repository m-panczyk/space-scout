extends VBoxContainer

var title = ''

var game_scene = "res://game.tscn"
var settings = preload("res://ui/settings.tscn")

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
	get_tree().change_scene_to_packed(load(game_scene))

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	get_parent().get_parent().replace_current_scene(settings)


func _on_save_game_pressed() -> void:
	SaveData.show_save_dialog()


func _on_continue_game_pressed() -> void:
	SaveData.load_latest_save()
	new_game()
