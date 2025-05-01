extends Control

var game_scene = preload("res://game.tscn")

var lobby:Lobby

func _ready() -> void:
	_on_resized()
	$Lobby.start_game.connect(_on_start_game)

func _on_start_game(player_config, level_config):
	$Lobby.hide_lobby()
	var new_level = $Lobby.create_game_level()
	add_child(new_level)

func training() -> void:
	$Lobby.visible = true

func new_game() -> void:
	get_tree().change_scene_to_packed(game_scene)

func continue_game() -> void:
	game_scene.load_game(0)
	get_tree().change_scene_to_packed(game_scene)

func _on_resized() -> void:
	var texture:CompressedTexture2D = $TextureRect.texture

	var screen_size:Vector2 = size
	var texture_size:Vector2 = texture.get_size()
	
	var new_size = min(texture_size.x,texture_size.y,screen_size.x,screen_size.y)
	
	$TextureRect.size = Vector2(new_size,new_size)
	$TextureRect.position = Vector2((size.x-new_size)/2,(size.y-new_size)/2)
	


func _on_exit_button_down() -> void:
	get_tree().quit()
