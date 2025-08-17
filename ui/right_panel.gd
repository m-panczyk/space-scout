extends Control

func _enter_tree() -> void:
	EventBus.subscribe('target_selected', restore_btn)
	EventBus.subscribe("start_lvl",start_lvl)


func _exit_tree() -> void:
	EventBus.unsubscribe('target_selected', restore_btn)
	EventBus.unsubscribe("start_lvl",start_lvl)
	
func start_lvl(_punished):
	%StartLevelButton.disabled = true

func restore_btn(target_position = null) -> void:
	%StartLevelButton.disabled = false

func _on_start_level_button_pressed() -> void:
	EventBus.emit("start_lvl",false)
	

func pass_focus() -> void:
	%HexTileController.grab_focus()
