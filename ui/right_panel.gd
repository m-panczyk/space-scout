extends VBoxContainer

func _enter_tree() -> void:
	EventBus.subscribe('target_selected', restore_btn)
	EventBus.subscribe('max_lvl_set',progress_setup)
	EventBus.subscribe('add_point',progress_update)

func _exit_tree() -> void:
	EventBus.unsubscribe('target_selected', restore_btn)
	EventBus.unsubscribe('max_lvl_set',progress_setup)
	EventBus.unsubscribe('add_point',progress_update)

func restore_btn(target_position = null) -> void:
	%StartLevelButton.disabled = false

func _on_start_level_button_pressed() -> void:
	EventBus.emit("start_lvl",false)
	%StartLevelButton.disabled = true

func progress_setup(max_lvl):
	$ProgressBar.value = 0
	$ProgressBar.max_value = max_lvl
	
func progress_update(points):
	$ProgressBar.value = $ProgressBar.value + points
