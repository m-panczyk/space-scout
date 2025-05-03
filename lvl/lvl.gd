extends Node2D
class_name GameLevel

@export var bg_type = "0"
@export var bg_speed = .1
@export var fall_speed = 100


var player:Player
var bg:LevelBackground

var screen_size:Vector2

func _ready() -> void:
	screen_size = GlobalSettings.virtual_resolution
	if SaveData.is_new:
		player = Player.new()
		bg = LevelBackground.new()
		player.position = Vector2(screen_size.x/2,screen_size.y*0.8)
	else:
		bg_type = SaveData.bg_type
		bg_speed = SaveData.bg_speed
		fall_speed = SaveData.fall_speed
		player = SaveData.get_player()
	bg.speed = bg_speed
	bg.lvl = bg_type
	add_child(bg)
	add_child(player)
	var player_size = player.get_size().x
	var player_scale = (screen_size.x/5)/player_size
	player.scale = Vector2(player_scale,player_scale)
