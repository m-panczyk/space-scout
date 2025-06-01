extends Sprite2D
class_name LevelBackground

# Private backing fields
var _speed = .1
var _lvl = "0"
@export var direction = Vector2(0,-1)

var screen_size

# Public properties with getters/setters
var speed:
	get:
		return _speed
	set(value):
		_speed = value
		SaveData.bg_speed = value
		if material:
			material.set_shader_parameter("speed", _speed)

var lvl:
	get:
		return _lvl
	set(value):
		_lvl = value
		SaveData.bg_type = value
		set_texture_for_lvl()

func _ready() -> void:
	if SaveData.bg_speed != null:
		_speed = SaveData.bg_speed
	if SaveData.bg_type != null:
		_lvl = SaveData.bg_type
	
	material = load("res://lvl/background/shaders/rollup.tres")
	material.set_shader_parameter("direction", direction)
	material.set_shader_parameter("speed", _speed)
	get_parent().item_rect_changed.connect(update_size)
	set_texture_for_lvl()
	update_size()

func _enter_tree() -> void:
	EventBus.subscribe('end_lvl', end_lvl)
	EventBus.subscribe('start_lvl', prepare_lvl)

func _exit_tree() -> void:
	EventBus.unsubscribe('end_lvl', end_lvl)
	EventBus.unsubscribe('start_lvl', prepare_lvl)

func prepare_lvl(punished:bool):
	if punished:
		material = load("res://hyper_shader_material.tres")

func end_lvl(success:bool):
	if success:
		material = load("res://lvl/background/shaders/rollup.tres")
		material.set_shader_parameter("speed", _speed)
		material.set_shader_parameter("direction", direction)

func set_texture_for_lvl() -> void:
	texture = load("res://lvl/background/img/" + _lvl + ".png")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
func update_size() -> void:
	screen_size = GlobalSettings.virtual_resolution

	position.x = screen_size.x/2
	position.y = screen_size.y/2
	
	var new_scale = max(float(screen_size.x) / texture.get_width(), float(screen_size.y) / texture.get_height())
	
	scale = Vector2(new_scale, new_scale)
	print("scale: " + str(scale))
