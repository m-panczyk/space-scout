extends Sprite2D
class_name LevelBackground

@export var speed = .1
@export var lvl  = "0"
@export var direction = Vector2(0,-1)

var screen_size

func _ready() -> void:
	texture = load("res://lvl/background/img/"+lvl+".tres")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	material = preload("res://lvl/background/shaders/rollup.tres")
	material.set_shader_parameter("direction",direction)
	material.set_shader_parameter("speed", speed)
	get_tree().get_root().size_changed.connect(update_size)
	update_size()
	
func update_size() -> void:
	screen_size = get_viewport_rect().size

	position.x = screen_size.x/2
	position.y = screen_size.y/2
	
	var new_scale = max(screen_size.x / texture.get_width(),screen_size.y/texture.get_height())
	scale = Vector2(new_scale,new_scale)
	
