extends Control

func _ready() -> void:
	#GlobalSettings.adjust_viewport_scale()
	#_on_resized()
	pass

func _on_resized() -> void:
	var texture: CompressedTexture2D = $TextureRect.texture
	var screen_size: Vector2 = get_tree().root.get_window().size
	print("root_ui size: ",screen_size)
	var texture_size: Vector2 = texture.get_size()
	
	var new_size = min(min(texture_size.x, texture_size.y), min(screen_size.x, screen_size.y))/GlobalSettings.scale_factor
	print("New size: ",new_size)
	$TextureRect.size = Vector2(new_size, new_size)
	#$TextureRect.position = Vector2((screen_size.x - new_size) / 2, (screen_size.y - new_size) / 2)
	#$TextureRect.position = Vector2(new_size / -2, new_size/ -2)
	print("New position: ",$TextureRect.position)
	#$TextureRect.get_child(0).size = Vector2(new_size, new_size)
	#$MenuContainer.size = screen_size - Vector2(100,100)
	#$MenuContainer.position = Vector2((size.x - $MenuContainer.size.x) / 2, (size.y - $MenuContainer.size.y) / 2)


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.hide()
