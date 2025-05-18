extends Node2D
class_name GameLevel

@export var bg_type = "0"
@export var bg_speed = .1
@export var fall_speed = 100

var env:EnvGenerator = null
var lvl_points = 0
var max_level_points = 100
@onready var player:Player = $Player
@onready var bg:LevelBackground = $LevelBackground
@onready var screen_size:Vector2 = GlobalSettings.virtual_resolution

func _enter_tree() -> void:
	EventBus.subscribe('start_lvl',start_lvl)
	EventBus.subscribe("add_point",end_lvl_check)
func _exit_tree() -> void:
	EventBus.unsubscribe("add_point",end_lvl_check)
	EventBus.unsubscribe('start_lvl',start_lvl)

func end_lvl_check(new_points:int):
	lvl_points += new_points
	if lvl_points >= max_level_points:
		get_tree().call_group("PORTALS","show_question")
		lvl_points = 0
		env.queue_free()
		env = null
func end_lvl(success:bool):
	EventBus.emit("end_lvl",success)
	env.queue_free()
	env = null

		
func start_lvl(punished:bool):
	max_level_points = 100/SaveData.game_progress
	bg.lvl = (str(randi_range(1,34)))
	env = EnvGenerator.new()
	env.base_speed = fall_speed
	lvl_points = 0
	add_child(env)
	
