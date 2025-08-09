extends Node2D
class_name GameLevel

@export var bg_type = "0"
@export var bg_speed = .1
@export var fall_speed = 10

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
		GameState.set_question()
		get_tree().call_group("PORTALS","show_question")
		lvl_points = 0
		env.ready_to_free = true

func start_lvl(punished:bool):
	if env != null:
		env.queue_free()
	max_level_points = lerp(50,10,(GameState.game_progress/20))
	EventBus.emit("max_lvl_set",max_level_points)
	if punished:
		bg.lvl = 0
	else:
		bg.lvl = (str(randi_range(1,34)))
	env = EnvGenerator.new()
	lvl_points = 0
	add_child(env)
	
