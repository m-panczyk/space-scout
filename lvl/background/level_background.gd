extends Sprite2D
class_name LevelBackground

@export var speed = .1
@export var lvl  = "0"
@export var direction = Vector2(0,-1)

var screen_size

func _ready() -> void:
	set_lvl(lvl)
	material = load("res://lvl/background/shaders/rollup.tres")
	material.set_shader_parameter("direction",direction)
	material.set_shader_parameter("speed", speed)
	get_parent().item_rect_changed.connect(update_size)
	update_size()

func _enter_tree() -> void:
	EventBus.subscribe('end_lvl',end_lvl)
	EventBus.subscribe('start_lvl',prepare_lvl)

func _exit_tree() -> void:
	EventBus.unsubscribe('end_lvl',end_lvl)
	EventBus.unsubscribe('start_lvl',prepare_lvl)

func prepare_lvl(punished:bool):
	if punished:
		material = load("res://hyper_shader_material.tres")

func end_lvl(success:bool):
	if success:
		material = load("res://lvl/background/shaders/rollup.tres")

func set_lvl(lvl_name:String):
	lvl = lvl_name
	texture = load("res://lvl/background/img/"+lvl+".png")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
func update_size() -> void:
	screen_size = GlobalSettings.virtual_resolution
	print(screen_size)
	print(texture.get_size())

	position.x = screen_size.x/2
	position.y = screen_size.y/2
	
	var new_scale = max(float(screen_size.x) / texture.get_width(),float(screen_size.y)/texture.get_height())
	
	scale = Vector2(new_scale,new_scale)
	print("scale: "+str(scale))
	
