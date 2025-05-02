extends VBoxContainer
var scene_history:Array = []
var current_scene

func _ready() -> void:
	current_scene = $CurrentScene

func replace_current_scene(new_scene: PackedScene) -> void:
	print("replacing current scene")
	var new_scene_instance = new_scene.instantiate()
	scene_history.push_back(current_scene)
	print(scene_history)
	remove_child(current_scene)
	current_scene = new_scene_instance
	add_child(current_scene)
	%Back.visible = !scene_history.is_empty()
	%Title.text = current_scene.title

func _on_back_pressed() -> void:
	print(scene_history)
	remove_child(current_scene)
	current_scene.queue_free()
	current_scene = scene_history.pop_back()
	add_child(current_scene)
	%Back.visible = !scene_history.is_empty()
	%Title.text = current_scene.title
