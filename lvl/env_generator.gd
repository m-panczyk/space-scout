extends Node
class_name EnvGenerator

var run = true
var pace_level = 3.0
var speed = 100
var level_points = 0
var added_item_speed = 0
var timer = 0.0
var screen_size
var spawn_points
var item_size

var correct_answers = [0,0,1]
var question = "Wybierz dobrą odpowiedź"
var answers = [
		"Zła",
		"Zła",
		"Dobra"
		]
@export var item_list = [
		[Asteroid,10]
		]

var last_position = null

func _ready() -> void:
	screen_size = get_viewport().size
	item_size = screen_size.x/5
	spawn_points = [
		Vector2(item_size*0.5,0),
		Vector2(item_size*1.5,0),
		Vector2(item_size*2.5,0),
		Vector2(item_size*3.5,0),
		Vector2(item_size*4.5,0)
	]
	
func pick_random_item():
		# Calculate total weight
		var total_weight = 0
		for item in item_list:
				total_weight += item[1]

		# Generate a random value between 0 and total weight
		var random_value = randf() * total_weight

		# Find the item that corresponds to the random value
		var current_weight = 0
		for item in item_list:
				current_weight += item[1]
				if random_value <= current_weight:
						return item[0]  # Return the item (scene)

		# Fallback (should never reach here if weights are positive)
		return item_list[0][0]
func pick_random_point():
		if last_position == null:
				last_position = randf() * 5
				return spawn_points[last_position]
		else:
				var stripped_spawn_points = spawn_points.remove_at(last_position)
				last_position = randf() * 4
				return stripped_spawn_points[last_position]

func spawn(item_class,position):
		var item = item_class.new()
		item.global_position = position
		item.speed = speed + added_item_speed
		add_child(item)
		#item_instance.owner = get_parent()

func _process(delta) -> void:
		if run:
				timer += delta
		if timer >= pace_level:
				if pace_level > 0.5:
						pace_level -= 0.1
				else:
						added_item_speed += 1
				spawn(pick_random_item(), spawn_points.pick_random())
				timer = 0.0
