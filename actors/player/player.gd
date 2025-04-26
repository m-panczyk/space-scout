extends Actor
class_name Player

func _init() -> void:
	if skin_path == "":
		skin_path = "res://actors/player/img/base_0.tscn"

func get_animation() -> AnimatedSprite2D:
	return get_child(0).get_child(0)
	
func get_size() -> Vector2:
	return get_animation().sprite_frames.get_frame_texture(get_animation().animation,0).get_size()

func _alt_ready() -> void:
	health_changed()
	collision_layer = 1
	collision_mask = 2

	

func health_change():
	EventBus.emit("health_changed", [health,max_health])

func process_move(delta: float):
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("ui_left"):
				get_animation().frame = 1
				velocity.x -=1
		if Input.is_action_pressed("ui_right"):
				get_animation().frame = 2
				velocity.x +=1
		if velocity.x == 0:
				get_animation().frame = 0
		if Input.is_action_pressed("ui_up"):
				velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
				velocity.y += 1
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		position += velocity * delta

func died():
	EventBus.emit("game_over",[false,0])
