extends Node2D
class_name GameLevel

@export var bg_type = "0"
@export var bg_speed = .1
@export var fall_speed = 100
#@export var player_speed = 400
#@export var player_health = 1

var player:Player
var bg:LevelBackground

var screen_size:Vector2

func _init(new_player:Player = Player.new()) -> void:
	player = new_player
	
	bg = LevelBackground.new()
	bg.speed = bg_speed
	bg.lvl = bg_type

func _ready() -> void:
	screen_size = GlobalSettings.virtual_resolution
	print("games_size:" + str(screen_size))
	add_child(bg)
	add_child(player)
	player.position = Vector2(screen_size.x/2,screen_size.y*0.8)
	var player_size = player.get_size().x
	var player_scale = (screen_size.x/5)/player_size
	player.scale = Vector2(player_scale,player_scale)
	var env_gen = EnvGenerator.new()
	env_gen.base_speed = fall_speed
	add_child(env_gen)
