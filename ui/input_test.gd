extends Button

@export var parent_to_hide:Control
@export var parent_for_test:Node
@export var test_scene:PackedScene

func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed():
	parent_to_hide.hide()
	var test_node = test_scene.instantiate()
	parent_for_test.get_parent().add_child(test_node)
	test_node.connect("tree_exiting",parent_to_hide.show)
