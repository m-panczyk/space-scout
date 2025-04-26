extends Actor
class_name Asteroid

func _init() -> void:
	if skin_path == "":
		skin_path = "res://actors/asteroid/img/small_1.tscn"
	
func _alt_ready() -> void:
	collision_layer = 2
	collision_mask = 7

func process_clamping() -> void:
	pass

func died():
	EventBus.emit_signal("add_point",max_health)
	queue_free()

func _on_screen_exited() -> void:
	died()
