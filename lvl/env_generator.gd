extends Node
class_name EnvGenerator

signal item_spawned(item)
signal difficulty_increased(level, speed)

# Configurable properties
@export var pace_level_start: float = 2.0
@export var pace_level_min: float = 0.5
@export var pace_level_decrement: float = 0.1
@export var base_speed: int = 100
@export var speed_increment: int = 1
@export var item_scale: float = 0.2  

# Player collision properties
@export var player_collision_radius: float = 30.0
@export var safety_margin: float = 10.0

# Runtime properties
var run: bool = true
var pace_level: float
var current_speed: int
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

# Emergency spawn control
var max_spawn_attempts: int = 0
var max_spawn_wait: float = 2.0

# Player reference
var player: Player

func _ready() -> void:
	screen_size = GlobalSettings.virtual_resolution
	item_size = screen_size.x * item_scale
	pace_level = pace_level_start
	current_speed = base_speed
	
	# Initialize spawn lanes
	_initialize_spawn_lanes()

	if item_list.is_empty():
		item_list = [[Asteroid, 10]]
	player = get_parent().player
	player_collision_radius = max(player.get_size().x, player.get_size().y)

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
		
		# Try to spawn safely
		var spawn_successful = attempt_safe_spawn()
		
		# Track failed attempts
		if not spawn_successful:
			max_spawn_attempts += 1
			
			# If we haven't spawned in a while, force a spawn to prevent stalling
			if timer >= max_spawn_wait:
				force_emergency_spawn()
				max_spawn_attempts = 0
				timer = 0.0
		else:
			max_spawn_attempts = 0
			timer = 0.0
		
		emit_signal("difficulty_increased", pace_level, current_speed)

func attempt_safe_spawn() -> bool:
	var item_class = pick_random_item()
	if not item_class:
		return false
	
	# Check if this is a good item (damage <= 0)
	var is_good_item = false
	if item_class.has_method("new"):
		var temp_item = item_class.new()
		if temp_item.get("damage") != null and temp_item.damage <= 0:
			is_good_item = true
		temp_item.queue_free()
	
	# First, try the standard lane selection
	var standard_position = pick_random_lane()
	if is_spawn_safe(standard_position, is_good_item):
		spawn(item_class, standard_position)
		return true
	
	# If that fails, try all lanes
	var safe_positions = find_all_safe_positions(is_good_item)
	if safe_positions.is_empty():
		# No safe position found, skip this spawn
		return false
	
	# Pick a random safe position
	var random_position = safe_positions[randi() % safe_positions.size()]
	spawn(item_class, random_position)
	return true

func find_all_safe_positions(is_good_item: bool) -> Array[Vector2]:
	var safe_positions: Array[Vector2] = []
	
	for lane_pos in spawn_lanes:
		if is_spawn_safe(lane_pos, is_good_item):
			safe_positions.append(lane_pos)
	
	return safe_positions

func is_spawn_safe(position: Vector2, is_good_item: bool) -> bool:
	# Good items can be spawned more liberally
	if is_good_item:
		# Only check basic vertical spacing for good items
		var recent_items = get_tree().get_nodes_in_group("items")
		var min_y_distance = 100.0  # Reduced spacing for good items
		
		for item in recent_items:
			# Skip if it's another good item
			if item.get("damage") != null and item.damage <= 0:
				continue
				
			var y_distance = abs(item.global_position.y - position.y)
			if y_distance < min_y_distance:
				return false
		
		return check_screen_boundaries(position)
	
	# For harmful items, check if at least one path remains clear
	var all_items = get_tree().get_nodes_in_group("items")
	
	# Get all harmful items within relevant distance
	var nearby_items = []
	var vertical_check_distance = 300.0  # Increased from overly restrictive value
	
	for item in all_items:
		# Skip good items when checking path blocking
		if item.get("damage") != null and item.damage <= 0:
			continue
			
		var y_distance = abs(item.global_position.y - position.y)
		if y_distance < vertical_check_distance:
			nearby_items.append(item)
	
	# If no nearby items, just check boundaries
	if nearby_items.is_empty():
		return check_screen_boundaries(position)
	
	# Check if at least one lane would remain clear
	return would_leave_clear_path(nearby_items, position) and \
		   check_screen_boundaries(position)

func would_leave_clear_path(existing_items: Array, new_position: Vector2) -> bool:
	# Simpler check: ensure at least one lane would be completely clear
	
	# Include the new item in our check
	var all_blocking_positions = []
	for item in existing_items:
		all_blocking_positions.append(item.global_position)
	all_blocking_positions.append(new_position)
	
	# Check each lane
	var clear_lanes = 0
	for i in range(spawn_lanes.size()):
		var lane_x = spawn_lanes[i].x
		var lane_clear = true
		
		# Check if this lane has any items too close
		for blocking_pos in all_blocking_positions:
			var distance = abs(lane_x - blocking_pos.x)
			# Use a more reasonable clearance requirement
			var required_clearance = item_size * 0.7  # Reduced from overly strict value
			
			if distance < required_clearance:
				lane_clear = false
				break
		
		if lane_clear:
			clear_lanes += 1
	
	# We need at least 2 clear lanes to ensure there's always a path
	return clear_lanes >= 2

# Simplified clearance check
func is_position_clear_of_item(player_x: float, item_position: Vector2) -> bool:
	var horizontal_distance = abs(player_x - item_position.x)
	# More lenient clearance requirements
	var required_clearance = item_size * 0.6  # About half an item width + small buffer
	return horizontal_distance >= required_clearance

func check_screen_boundaries(position: Vector2) -> bool:
	# Ensure item doesn't spawn too close to screen edges
	var edge_buffer = item_size * 0.3  # Minimal edge buffer
	return position.x >= edge_buffer and \
		   position.x <= screen_size.x - edge_buffer

func force_emergency_spawn():
	# Last resort: spawn with reduced safety requirements
	var item_class = pick_random_item()
	if not item_class:
		return
	
	# Try to find the safest available position
	var best_position = find_least_crowded_position()
	
	if best_position != Vector2.ZERO:
		spawn(item_class, best_position)
	
	# Clear some old items if needed
	clear_oldest_items_if_needed()

func find_least_crowded_position() -> Vector2:
	var best_position = Vector2.ZERO
	var max_clearance = 0.0
	
	for lane_pos in spawn_lanes:
		var clearance = calculate_clearance_at_position(lane_pos)
		if clearance > max_clearance:
			max_clearance = clearance
			best_position = lane_pos
	
	return best_position

func calculate_clearance_at_position(position: Vector2) -> float:
	var min_distance = INF
	
	for item in get_tree().get_nodes_in_group("items"):
		# Only consider harmful items for clearance calculation
		if item.get("damage") != null and item.damage > 0:
			var distance = position.distance_to(item.global_position)
			min_distance = min(min_distance, distance)
	
	return min_distance

func clear_oldest_items_if_needed():
	var items = get_tree().get_nodes_in_group("items")
	
	# Sort by y position (oldest items are lower)
	items.sort_custom(func(a, b): return a.global_position.y > b.global_position.y)
	
	# Remove the bottom 20% of harmful items to create space
	var items_to_remove = int(items.size() * 0.2)
	var removed_count = 0
	
	for item in items:
		if removed_count >= items_to_remove:
			break
			
		# Only remove harmful items
		if item.get("damage") != null and item.damage > 0:
			item.queue_free()
			removed_count += 1

func pause() -> void:
	run = false

func resume() -> void:
	run = true

func reset() -> void:
	pace_level = pace_level_start
	current_speed = base_speed
	added_item_speed = 0
	timer = 0.0
	last_lane_index = -1
	max_spawn_attempts = 0
	
	# Clear existing items
	get_tree().call_group("items", "queue_free")
