extends Label

func _ready() -> void:
	update(0)
	EventBus.subscribe("end_lvl",update)
	EventBus.subscribe("start_lvl",update)
	
func update(_punished):
	text = str(GameState.game_progress," game progress")
	
func _exit_tree() -> void:
	EventBus.unsubscribe("end_lvl",update)
	EventBus.unsubscribe("start_lvl",update)
