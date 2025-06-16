extends Node
class_name EnvGenerator

var base_speed = 0
var item_list = [[Asteroid, 10]]
var spawn_points: Array[Vector2]
var last_item: Actor

func _ready() -> void:
	setup_spawn_points()

func weighted_pick(item_list: Array) -> Actor:
	if item_list.is_empty(): 
		return null
	
	var total = 0.0
	for entry in item_list: 
		total += entry[1]
	
	if total <= 0: 
		return null
	
	var rand = randf() * total
	var current = 0.0
	
	for entry in item_list:
		current += entry[1]
		if rand <= current: 
			return entry[0].new()  # Instantiate the class
	
	return item_list[-1][0].new()  # Instantiate the class

func setup_spawn_points() -> void:
	var start_pos = Vector2(0, 0)
	var end_pos = Vector2(GlobalSettings.virtual_resolution.x, 0)
	spawn_points = []
	
	for i in range(1, 6):
		var point = start_pos + (end_pos - start_pos) * i / 6.0
		spawn_points.append(point)

func spawn() -> void:
	last_item = weighted_pick(item_list)
	last_item.speed = base_speed
	base_speed += base_speed * .01
	last_item.position = spawn_points[randi() % spawn_points.size()]
	add_child(last_item)

func _process(delta: float) -> void:
	# Check if we need to spawn a new item
	if last_item == null or not is_instance_valid(last_item):
		spawn()
	elif last_item.position.y > 150:
		spawn()
