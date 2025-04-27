extends Node
class_name EnvGenerator

signal item_spawned(item)
signal difficulty_increased(level, speed)

# Configurable properties
@export var pace_level_start: float = 1.0
@export var pace_level_min: float = 0.5
@export var pace_level_decrement: float = 0.1
@export var base_speed: int = 100
@export var speed_increment: int = 1
@export var item_scale: float = 0.2  

# Runtime properties
var run: bool = true
var pace_level: float
var current_speed: int
var level_points: int = 0
var timer: float = 0.0
var screen_size: Vector2
var spawn_lanes: Array[Vector2] = []
var item_size: float
var last_lane_index: int = -1

var item_list = [] 

# Quiz system properties
var correct_answers = [0, 0, 1]
var question = "Wybierz dobrą odpowiedź"
var answers = [
	"Zła",
	"Zła",
	"Dobra"
]

# This is included for compatibility with original code
var added_item_speed: int = 0

func _ready() -> void:
	screen_size = GlobalSettings.virtual_resolution
	item_size = screen_size.x * item_scale
	pace_level = pace_level_start
	current_speed = base_speed
	
	# Initialize spawn lanes
	_initialize_spawn_lanes()

	if item_list.is_empty():
		item_list = [[Asteroid, 10]]

func _initialize_spawn_lanes() -> void:
	spawn_lanes.clear()
	var lane_count: int = 5
	
	for i in range(lane_count):
		spawn_lanes.append(Vector2(item_size * (i + 0.5), 0))

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
			return item[0]  # Return the class reference directly

	# Fallback (should never reach here if weights are positive)
	return item_list[0][0] if !item_list.is_empty() else null

func pick_random_lane() -> Vector2:
	var available_indices = range(spawn_lanes.size())
	
	# Avoid using the same lane twice in a row if possible
	if last_lane_index != -1 and spawn_lanes.size() > 1:
		available_indices.erase(last_lane_index)
	
	var chosen_index = available_indices[randi() % available_indices.size()]
	last_lane_index = chosen_index
	
	return spawn_lanes[chosen_index]

func spawn(item_class, position: Vector2) -> Node:
	if item_class == null:
		push_error("Attempted to spawn null item class")
		return null
		
	# Create new instance of the class
	var item = item_class.new()
	item.global_position = position
	
	# Set speed property if it exists
	if item.get("speed") != null:
		item.speed = current_speed + added_item_speed
		
	add_child(item)
	emit_signal("item_spawned", item)
	return item

func _process(delta: float) -> void:
	if !run:
		return
		
	timer += delta
	
	if timer >= pace_level:
		# Increase difficulty
		if pace_level > pace_level_min:
			pace_level -= pace_level_decrement
		else:
			added_item_speed += speed_increment
			get_tree().call_group("items", "accelerate", speed_increment)
		
		# Spawn new item
		var item_class = pick_random_item()
		if item_class:
			var position = pick_random_lane()
			spawn(item_class, position)
		
		emit_signal("difficulty_increased", pace_level, current_speed)
		timer = 0.0

func pause() -> void:
	run = false

func resume() -> void:
	run = true

func reset() -> void:
	pace_level = pace_level_start
	current_speed = base_speed
	level_points = 0
	added_item_speed = 0
	timer = 0.0
	last_lane_index = -1
	
	# Clear existing items
	get_tree().call_group("items", "queue_free")
