extends MarginContainer

func _ready() -> void:
	_on_resized()

func _on_resized() -> void:
	var texture: CompressedTexture2D = $TextureRect.texture
	var screen_size: Vector2 = size
	var texture_size: Vector2 = texture.get_size()
	
	var new_size = min(min(texture_size.x, texture_size.y), min(screen_size.x, screen_size.y))
	
	$TextureRect.size = Vector2(new_size, new_size)
	$TextureRect.position = Vector2((size.x - new_size) / 2, (size.y - new_size) / 2)
