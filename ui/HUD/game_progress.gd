extends Label

func _ready() -> void:
	EventBus.subscribe('add_point',progress_update)
	EventBus.subscribe('max_lvl_set',progress_setup)
	
func _exit_tree() -> void:
	EventBus.unsubscribe('max_lvl_set',progress_setup)
	EventBus.unsubscribe('add_point',progress_update)

func progress_setup(max_lvl):
	get_parent().value = 0
	get_parent().max_value = max_lvl
	
func progress_update(points):
	get_parent().value = get_parent().value + points
	text = str(int(get_parent().value))
