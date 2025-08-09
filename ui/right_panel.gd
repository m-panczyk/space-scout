extends Control

func _enter_tree() -> void:
	EventBus.subscribe('target_selected', restore_btn)


func _exit_tree() -> void:
	EventBus.unsubscribe('target_selected', restore_btn)


func restore_btn(target_position = null) -> void:
	%StartLevelButton.disabled = false

func _on_start_level_button_pressed() -> void:
	EventBus.emit("start_lvl",false)
	%StartLevelButton.disabled = true
