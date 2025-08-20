extends Control
class_name ControlTest

@export var moving_actions:Array[StringName] = [
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down",
]
@export var shooting_actions:Array[StringName] = [
	"game_fire"
	]
@export var ui_actions:Array[StringName] = [
	"show_player_stats",
	"show_map",
	"show_gameplay",
	"panel_left",
	"panel_right"
]
@onready var categories:Array[Array] = [
	moving_actions,
	shooting_actions,
	ui_actions
]
var stages:Array[Callable] = [
	handle_move,
	handle_shot,
	handle_ui
]
@export var commands:Array[String] = [
	"Test systemów bojowych",
	"Test interfejsu",
	"Test obsługi interfejsu"
]
@export var visual_clues:Array[Control]
@onready var current_array:Array[StringName] = categories.pop_front()
@onready var handle_function:Callable = stages.pop_front()
@onready var current_container:Control = visual_clues.pop_front()

func _input(event: InputEvent) -> void:
	if event.is_action_type():
		for i in range(current_array.size()):
			if event.is_action(current_array[i]):
				handle_function.call(i)
				#handle_move(i)
				break
func next_part():
	if stages.size() > 0 and visual_clues.size() > 0:
		handle_function = stages.pop_front()
		$Command.text = commands.pop_front()
		current_container = visual_clues.pop_front()
		for node in (current_container.get_children() + [current_container]):
			print(node.name)
		current_container.show()
		current_array.clear()
		current_array = categories.pop_front()
	else:
		queue_free()
func handle_move(index:int):
	var action_name = current_array.pop_at(index)
	current_container.find_child(action_name).queue_free()
	if current_container.get_child_count() <= 1:
		current_container.queue_free()
		next_part()
func handle_shot(index:int):
	$game_fire.queue_free()
	next_part()

func handle_ui(index:int):
	handle_move(index)


	
