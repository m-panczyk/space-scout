extends Label

func _ready() -> void:
	EventBus.subscribe("add_point",update)
	
func update(new_points:int):
	SaveData.points += new_points
	text = str(SaveData.points," pts")
	
func _exit_tree() -> void:
	EventBus.unsubscribe("add_point",update)
