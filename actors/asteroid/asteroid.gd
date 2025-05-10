extends Actor
class_name Asteroid

func _init() -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN
	if skin_path == "":
		skin_path = "res://actors/asteroid/img/small_1.tscn"
	
func _alt_ready() -> void:
	collision_layer = 2
	collision_mask = 5
	damage = 1
	add_to_group("items")

func process_clamping() -> void:
	pass

func accelerate(acceleration:float):
	speed += acceleration

func died():
	EventBus.emit("add_point",max_health)
	queue_free()
