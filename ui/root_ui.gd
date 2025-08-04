extends Control
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func  _input(event: InputEvent) -> void:
	if is_instance_valid(video_player) and event.is_pressed():
		_on_video_stream_player_finished()
		
func _on_resized() -> void:
	var texture: CompressedTexture2D = $TextureRect.texture
	var screen_size: Vector2 = get_tree().root.get_window().size
	print("root_ui size: ",screen_size)
	var texture_size: Vector2 = texture.get_size()
	
	var new_size = min(min(texture_size.x, texture_size.y), min(screen_size.x, screen_size.y))/GlobalSettings.scale_factor
	$TextureRect.size = Vector2(new_size, new_size)

func _on_video_stream_player_finished() -> void:
	video_player.hide()
	video_player.queue_free()
