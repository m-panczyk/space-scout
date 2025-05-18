extends ColorRect

func _ready() -> void:
	$Stats.text += SaveData.get_pretty_stats()
func _input(event: InputEvent) -> void:
	if event.is_action_type():
		if !$VideoStreamPlayer.is_playing():
			get_tree().change_scene_to_file("res://ui/root_ui.tscn")
	
func _on_video_stream_player_finished() -> void:
	$AnimationPlayer.play("fade")
