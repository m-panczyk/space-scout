extends Node
class_name EnvGenerator

var base_speed = 0
var item_list = [[Asteroid, 10]]
var spawn_points: Array[Vector2]
var spawned_items: Array[Array] = []  # Array of arrays, one for each spawn point
var spawned_items_by_type_and_point: Array[Dictionary] = []  # Track items by type per spawn point
var min_spawn_distance = 200.0  # Minimum distance before spawning new item
var spawn_rate = 2.0  # Maximum spawns per second (across all spawn points)
var spawn_timer: Timer
var ready_to_free = false
var max_items_per_type_per_point = 3  # Maximum number of items of the same type per spawn point

# Difficulty scaling parameters
var min_spawn_rate = 0.5  # Easiest level spawn rate (level 20)
var max_spawn_rate = 5.0  # Hardest level spawn rate (level 0)
var min_base_speed = 50.0  # Easiest level speed (level 20)
var max_base_speed = 300.0  # Hardest level speed (level 0)

func _ready() -> void:
	randomize()
	setup_spawn_points()
	update_difficulty_from_progress()
	setup_spawn_timer()

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

func get_item_count_by_type_at_point(spawn_index: int, type_name: String) -> int:
	if spawn_index >= spawned_items_by_type_and_point.size():
		return 0
	
	var type_dict = spawned_items_by_type_and_point[spawn_index]
	if not type_dict.has(type_name):
		return 0
	
	var items = type_dict[type_name]
	# Clean up invalid references
	for i in range(items.size() - 1, -1, -1):
		if not is_instance_valid(items[i]):
			items.remove_at(i)
	
	return items.size()

func add_item_to_type_tracking(item: Actor, spawn_index: int) -> void:
	if spawn_index >= spawned_items_by_type_and_point.size():
		return
	
	var type_name = item.get_script().get_global_name() if item.get_script() else str(item.get_class())
	if not type_name:
		type_name = str(item.get_class())
	
	var type_dict = spawned_items_by_type_and_point[spawn_index]
	if not type_dict.has(type_name):
		type_dict[type_name] = []
	
	type_dict[type_name].append(item)

func remove_item_from_type_tracking(item: Actor, spawn_index: int) -> void:
	if spawn_index >= spawned_items_by_type_and_point.size():
		return
	
	var type_name = item.get_script().get_global_name() if item.get_script() else str(item.get_class())
	if not type_name:
		type_name = str(item.get_class())
	
	var type_dict = spawned_items_by_type_and_point[spawn_index]
	if type_dict.has(type_name):
		type_dict[type_name].erase(item)

func can_spawn_type_at_point(spawn_index: int, item_type: Actor) -> bool:
	var type_name = item_type.get_script().get_global_name() if item_type.get_script() else str(item_type.get_class())
	if not type_name:
		type_name = str(item_type.get_class())
	
	var current_count = get_item_count_by_type_at_point(spawn_index, type_name)
	return current_count < max_items_per_type_per_point

func setup_spawn_points() -> void:
	var start_pos = Vector2(0, 0)
	var end_pos = Vector2(GlobalSettings.virtual_resolution.x, 0)
	spawn_points = []
	spawned_items = []
	spawned_items_by_type_and_point = []
	
	for i in range(0, 7):
		var point = start_pos + (end_pos - start_pos) * i / 6.0
		spawn_points.append(point)
		spawned_items.append([])  # Initialize empty array for each spawn point
		spawned_items_by_type_and_point.append({})  # Initialize empty dictionary for each spawn point

func setup_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.0 / spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	add_child(spawn_timer)

func update_difficulty_from_progress() -> void:
	# Clamp game_progress to valid range
	var progress = clamp(GameState.game_progress, 0, 20)
	
	# Calculate difficulty factor (0.0 = hardest, 1.0 = easiest)
	var difficulty_factor = progress / 20.0
	
	# Update spawn rate (inverse: easier = slower spawn, harder = faster spawn)
	spawn_rate = lerp(max_spawn_rate, min_spawn_rate, difficulty_factor)
	
	# Update base speed (inverse: easier = slower speed, harder = faster speed)
	base_speed = lerp(max_base_speed, min_base_speed, difficulty_factor)
	
	# Update timer if it exists
	if spawn_timer:
		spawn_timer.wait_time = 1.0 / spawn_rate
	
	print("Difficulty updated - Progress: ", progress, " Spawn Rate: ", spawn_rate, " Base Speed: ", base_speed)

func spawn_at_point(spawn_index: int) -> void:
	var new_item = weighted_pick(item_list)
	if new_item == null:
		return
		
	new_item.speed = base_speed
	base_speed += base_speed * .01
	new_item.position = spawn_points[spawn_index]
	add_child(new_item)
	
	# Add to the spawned items list for this spawn point
	spawned_items[spawn_index].append(new_item)
	
	# Add to type tracking for this spawn point
	add_item_to_type_tracking(new_item, spawn_index)
	
	# Connect to the item's tree_exiting signal to clean up when it's freed
	new_item.tree_exiting.connect(_on_item_freed.bind(new_item, spawn_index))
	
	EventBus.emit('add_point', new_item.max_health)

func _on_spawn_timer_timeout() -> void:
	# Timer has finished, we can spawn again
	pass

func _on_item_freed(item: Actor, spawn_index: int) -> void:
	# Remove the item from our tracking list
	if spawn_index < spawned_items.size():
		spawned_items[spawn_index].erase(item)
	
	# Remove from type tracking
	remove_item_from_type_tracking(item, spawn_index)

func can_spawn_at_point(spawn_index: int) -> bool:
	if spawn_index >= spawned_items.size():
		return false
		
	var items_at_point = spawned_items[spawn_index]
	
	# If no items at this spawn point, we can spawn
	if items_at_point.is_empty():
		return true
	
	# Check if the last spawned item is far enough away
	var last_item = items_at_point[-1]  # Get the most recently spawned item
	
	# Make sure the item is still valid
	if not is_instance_valid(last_item):
		# Clean up invalid reference
		items_at_point.erase(last_item)
		return can_spawn_at_point(spawn_index)  # Recursive check after cleanup
	
	# Check distance from spawn point
	var distance_from_spawn = last_item.position.distance_to(spawn_points[spawn_index])
	return distance_from_spawn >= min_spawn_distance

func cleanup_invalid_items() -> void:
	# Clean up any invalid item references from spawn points
	for i in range(spawned_items.size()):
		var items_at_point = spawned_items[i]
		for j in range(items_at_point.size() - 1, -1, -1):  # Iterate backwards
			if not is_instance_valid(items_at_point[j]):
				items_at_point.remove_at(j)
	
	# Clean up invalid item references from type tracking
	for i in range(spawned_items_by_type_and_point.size()):
		var type_dict = spawned_items_by_type_and_point[i]
		for type_name in type_dict.keys():
			var items = type_dict[type_name]
			for j in range(items.size() - 1, -1, -1):  # Iterate backwards
				if not is_instance_valid(items[j]):
					items.remove_at(j)

func _process(delta: float) -> void:
	if ready_to_free:
		# Check if all items are cleared before freeing
		var all_clear = true
		for items_at_point in spawned_items:
			if not items_at_point.is_empty():
				all_clear = false
				break
		if all_clear:
			queue_free()
	else:
		# Clean up invalid references periodically
		cleanup_invalid_items()
		
		# Check if we can spawn and timer allows it
		if spawn_timer.is_stopped():
			var spawn_index = find_best_spawn_point()
			if spawn_index != -1:
				spawn_at_point(spawn_index)
				# Start the timer to enforce spawn rate
				spawn_timer.start()

# Helper function to get all currently active items
func get_all_active_items() -> Array[Actor]:
	var all_items: Array[Actor] = []
	for items_at_point in spawned_items:
		for item in items_at_point:
			if is_instance_valid(item):
				all_items.append(item)
	return all_items

# Helper function to get items at a specific spawn point
func get_items_at_spawn_point(spawn_index: int) -> Array:
	if spawn_index >= 0 and spawn_index < spawned_items.size():
		return spawned_items[spawn_index].duplicate()  # Return copy to prevent external modification
	return []

# Helper function to set the minimum spawn distance
func set_min_spawn_distance(distance: float) -> void:
	min_spawn_distance = distance

# Helper function to set the spawn rate (asteroids per second)
func set_spawn_rate(rate: float) -> void:
	spawn_rate = max(0.1, rate)  # Minimum rate of 0.1 per second to prevent issues
	if spawn_timer:
		spawn_timer.wait_time = 1.0 / spawn_rate

# Helper function to get current spawn rate
func get_spawn_rate() -> float:
	return spawn_rate

# Helper functions for difficulty scaling
func set_difficulty_range(min_spawn: float, max_spawn: float, min_speed: float, max_speed: float) -> void:
	min_spawn_rate = min_spawn
	max_spawn_rate = max_spawn
	min_base_speed = min_speed
	max_base_speed = max_speed
	update_difficulty_from_progress()

func get_current_difficulty_factor() -> float:
	# Returns 0.0 (hardest) to 1.0 (easiest)
	return clamp(GameState.game_progress, 0, 20) / 20.0

func refresh_difficulty() -> void:
	# Call this when game_progress changes during gameplay
	update_difficulty_from_progress()

# Helper function to set the maximum items per type per spawn point
func set_max_items_per_type_per_point(max_count: int) -> void:
	max_items_per_type_per_point = max(1, max_count)  # Minimum of 1 to prevent issues

# Helper function to get current count of a specific item type at a spawn point
func get_items_of_type_at_point(spawn_index: int, type_name: String) -> Array:
	if spawn_index >= spawned_items_by_type_and_point.size():
		return []
	
	var type_dict = spawned_items_by_type_and_point[spawn_index]
	if not type_dict.has(type_name):
		return []
	
	var valid_items = []
	var items = type_dict[type_name]
	for item in items:
		if is_instance_valid(item):
			valid_items.append(item)
	
	return valid_items

func find_best_spawn_point() -> int:
	# Get player position
	var player_nodes = get_tree().get_nodes_in_group("PLAYER")
	if player_nodes.is_empty():
		# No player found, use random valid spawn point
		return find_random_valid_spawn_point()
	
	var player = player_nodes[0]  # Get first player
	var player_x = player.global_position.x
	
	# Find the closest spawn point to player
	var best_spawn_index = -1
	var closest_distance = INF
	
	for i in range(spawn_points.size()):
		var distance_x = abs(spawn_points[i].x - player_x)
		if distance_x < closest_distance:
			closest_distance = distance_x
			best_spawn_index = i
	
	# Try the closest spawn point first
	if best_spawn_index != -1:
		# Check if we can spawn at this point (includes min_spawn_distance check)
		if can_spawn_at_point(best_spawn_index):
			# Also check if we can spawn the selected item type there
			var test_item = weighted_pick(item_list)
			if test_item != null:
				if can_spawn_type_at_point(best_spawn_index, test_item):
					test_item.queue_free()  # Clean up the test item
					return best_spawn_index
				else:
					test_item.queue_free()  # Clean up the test item
	
	# If closest spawn point doesn't work, use random valid spawn point
	return find_random_valid_spawn_point()

func find_spawn_point_for_item_type(item_type: Actor) -> int:
	# Find any spawn point that can spawn this item type
	var valid_points: Array[int] = []
	
	for i in range(spawn_points.size()):
		if can_spawn_at_point(i) and can_spawn_type_at_point(i, item_type):
			valid_points.append(i)
	
	# Return random valid point for this type or -1 if none available
	if valid_points.is_empty():
		return -1
	else:
		return valid_points[randi() % valid_points.size()]

func find_random_valid_spawn_point() -> int:
	# Get all valid spawn points (ignoring type limits)
	var valid_points: Array[int] = []
	for i in range(spawn_points.size()):
		if can_spawn_at_point(i):
			valid_points.append(i)
	
	# Return random valid point or -1 if none available
	if valid_points.is_empty():
		return -1
	else:
		return valid_points[randi() % valid_points.size()]

# ADDITIONAL: Helper function to check if any spawn point can spawn
func has_available_spawn_points() -> bool:
	for i in range(spawn_points.size()):
		if can_spawn_at_point(i):
			return true
	return false

# ADDITIONAL: Get spawn point status for debugging
func get_spawn_point_status() -> Array[Dictionary]:
	var status: Array[Dictionary] = []
	for i in range(spawn_points.size()):
		var point_status = {
			"index": i,
			"position": spawn_points[i],
			"can_spawn": can_spawn_at_point(i),
			"item_count": spawned_items[i].size(),
			"last_item_distance": 0.0
		}
		
		# Calculate distance of last item from spawn point
		if not spawned_items[i].is_empty():
			var last_item = spawned_items[i][-1]
			if is_instance_valid(last_item):
				point_status.last_item_distance = last_item.position.distance_to(spawn_points[i])
		
		status.append(point_status)
	
	return status
