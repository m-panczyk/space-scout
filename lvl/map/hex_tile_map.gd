extends TileMapLayer
class_name HexTileMap

var _ship_position = SaveData.ship_position
var ship_position:
	get:
		return _ship_position
	set(value):
		_ship_position = value
		SaveData.ship_position = value
var target = null
var last_pressed = null
var _endgame = SaveData.endgame
var endgame:
	get: return _endgame
	set(value):
		_endgame = value
		SaveData.endgame = value
var _explored = SaveData.explored_tiles
var explored:
	get:
		return _explored
	set(value):
		_explored = value
		SaveData.explored_tiles = value
var max_distance = 10  # Maximum possible distance for color gradient calculation
var lock = false

# Reference to the background color layer
var background_layer: TileMapLayer
# Dictionary to store label nodes for each explored tile
var tile_labels: Dictionary = {}

func _ready() -> void:
	# Ensure we have the latest data from SaveData
	_explored = SaveData.explored_tiles
	_ship_position = SaveData.ship_position
	
	# Start the setup chain
	call_deferred("complete_setup")

func complete_setup() -> void:
	# Create or get background layer first
	setup_background_layer()
	
	# Then generate background colors after layer is created
	call_deferred("finish_setup")

func finish_setup() -> void:
	# Check if this is a new game (no explored tiles)
	if explored.size() == 0:
		initialize_new_game_positions()
	
	# Generate the background color grid (now background_layer exists)
	generate_background_colors()
	
	for cell in explored:
		reset_cell(cell)
		create_distance_label(cell)
	set_ship_position(ship_position)

func create_distance_label(cell: Vector2i) -> void:
	"""Create a distance label for the given cell"""
	var distance = calculate_hex_distance(cell, endgame)
	
	# Remove existing label if it exists
	if tile_labels.has(cell):
		tile_labels[cell].queue_free()
	
	# Create new label
	var label = Label.new()
	label.text = str(distance)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position the label at the tile's world position
	var world_pos = map_to_local(cell)
	label.position = world_pos - Vector2(12, 12)  # Center the label (adjust based on font size)
	label.size = Vector2(24, 24)
	
	# Add label to the scene
	add_child(label)
	tile_labels[cell] = label

func update_distance_label(cell: Vector2i) -> void:
	"""Update the distance label for the given cell"""
	if tile_labels.has(cell):
		var distance = calculate_hex_distance(cell, endgame)
		tile_labels[cell].text = str(distance)

func remove_distance_label(cell: Vector2i) -> void:
	"""Remove the distance label for the given cell"""
	if tile_labels.has(cell):
		tile_labels[cell].queue_free()
		tile_labels.erase(cell)

func initialize_new_game_positions() -> void:
	"""Initialize new ship and endgame positions when no tiles are explored"""
	if explored.size() > 0:
		return  # Only run if no tiles are explored
	
	# Define the 10x10 grid bounds (adjust these based on your actual grid)
	var grid_min = Vector2i(0, 0)
	var grid_max = Vector2i(9, 9)
	
	# Generate random ship position within the grid
	var new_ship_pos = Vector2i(
		randi_range(grid_min.x, grid_max.x),
		randi_range(grid_min.y, grid_max.y)
	)
	
	# Find all valid positions exactly 5 tiles away from ship
	var valid_endgame_positions = []
	
	# Check all positions in the grid
	for x in range(grid_min.x, grid_max.x + 1):
		for y in range(grid_min.y, grid_max.y + 1):
			var potential_endgame = Vector2i(x, y)
			var distance = calculate_hex_distance(new_ship_pos, potential_endgame)
			
			if distance == 5:
				valid_endgame_positions.append(potential_endgame)
	
	# If no valid positions found (shouldn't happen on 10x10 grid), 
	# try a different ship position
	var max_attempts = 50
	var attempts = 0
	
	while valid_endgame_positions.size() == 0 and attempts < max_attempts:
		attempts += 1
		new_ship_pos = Vector2i(
			randi_range(grid_min.x, grid_max.x),
			randi_range(grid_min.y, grid_max.y)
		)
		
		valid_endgame_positions.clear()
		for x in range(grid_min.x, grid_max.x + 1):
			for y in range(grid_min.y, grid_max.y + 1):
				var potential_endgame = Vector2i(x, y)
				var distance = calculate_hex_distance(new_ship_pos, potential_endgame)
				
				if distance == 5:
					valid_endgame_positions.append(potential_endgame)
	
	# Select random endgame position from valid options
	if valid_endgame_positions.size() > 0:
		var new_endgame_pos = valid_endgame_positions[randi() % valid_endgame_positions.size()]
		
		# Set the new positions
		ship_position = new_ship_pos
		endgame = new_endgame_pos
		
		# Update the display
		set_ship_position(ship_position)
		set_endgame_position(endgame)
		
		# Clear explored tiles since this is a new game
		explored.clear()
		SaveData.explored_tiles = explored
		
		print("New game initialized:")
		print("Ship position: ", ship_position)
		print("Endgame position: ", endgame)
		print("Distance: ", calculate_hex_distance(ship_position, endgame))
	else:
		print("Error: Could not find valid endgame position 5 tiles away from ship")

func setup_background_layer() -> void:
	# Check if background layer already exists
	var parent = get_parent()
	background_layer = parent.get_node_or_null("BackgroundColorLayer")
	
	if not background_layer:
		# Create new background layer
		background_layer = TileMapLayer.new()
		background_layer.name = "BackgroundColorLayer"
		background_layer.z_index = -1  # Put it behind the main layer
		background_layer.tile_set = tile_set  # Use the same tileset
		parent.add_child(background_layer)
		# Move it to be the first child (bottom layer)
		parent.move_child(background_layer, 0)

func generate_background_colors() -> void:
	# Generate colors for a reasonable area around the game world
	# Adjust this range based on your game world size
	var world_size = 10  # Generate colors for 20x20 area around center
	
	for x in range(-world_size, world_size + 1):
		for y in range(-world_size, world_size + 1):
			var cell = Vector2i(x, y)
			var distance = calculate_hex_distance(cell, endgame)
			var tile_id = get_tile_id_from_distance(distance)
			
			# Set background color tile (layer 1 for color tiles)
			background_layer.set_cell(cell, 1, Vector2i(0, 0), tile_id)

func _input(event: InputEvent) -> void:
	print("direct_map_input:"+str(event))
	if lock:
		return
	if event is InputEventMouse || event is InputEventScreenTouch:
		# Get the camera
		var camera = %Camera2D
		# Get screen position
		var screen_pos = event.position
		# Convert screen position to global position using the camera
		var global_pos = screen_to_global(screen_pos, camera)
		# Convert global position to local position on the tilemap
		var local_pos = to_local(global_pos)
		# Convert local position to cell coordinates
		var clicked_cell = local_to_map(local_pos)
		# Handle cell selection
		handle_cell_selection(clicked_cell, event.is_pressed(),false)
	# Handle directional movement input actions
	if Input.is_action_just_pressed("ui_up"):
		print("up")
		move_target_direction("up")
	elif Input.is_action_just_pressed("ui_down"):
		print("down")
		move_target_direction("down")
	elif Input.is_action_just_pressed("ui_left"):
		move_target_direction("left")
		print("left")
	elif Input.is_action_just_pressed("ui_right"):
		print("right")
		move_target_direction("right")
	elif event.is_action("ui_accept"):
		EventBus.emit("start_lvl",false)


func handle_cell_selection(clicked_cell: Vector2i, is_pressed: bool, is_synth: bool) -> void:
	# Initialize last_pressed if it's the first click
	if last_pressed == null:
		last_pressed = clicked_cell
		
	# Only process clicks on surrounding cells
	if get_surrounding_cells(ship_position).has(clicked_cell) || is_synth:
		# Handle click event for setting target
		if is_pressed:
			if target != null:
				reset_cell(target)
			target = clicked_cell
			set_cell(target, 3, Vector2i(0, 0), 2)  # Set target visual
			
			# Emit target_selected signal
			EventBus.emit('target_selected', target)

func set_ship_position(new_ship_position: Vector2i = Vector2i(5, 5)) -> void:
	reset_cell(ship_position)
	ship_position = new_ship_position
	set_cell(ship_position, 3, Vector2i(0, 0))  # Set ship visual
	
	# Create or update distance label for ship position
	create_distance_label(ship_position)
	
	# Update camera position
	%Camera2D.position = map_to_local(ship_position)
	GameState.game_progress = calculate_hex_distance(ship_position,endgame)

func reset_cell(cell: Vector2i) -> void:
	if explored.has(cell):
		# For explored cells, use transparent tile to reveal background color
		set_cell(cell, 2, Vector2i(0, 0), get_tile_id_from_distance(calculate_hex_distance(cell,endgame)))  # Transparent/explored tile
		# Ensure distance label exists for explored cells
		if not tile_labels.has(cell):
			create_distance_label(cell)
	else:
		# For unexplored cells, use opaque tile to hide background
		set_cell(cell, 0, Vector2i.ZERO, 1)  # Opaque/unexplored tile
		# Remove distance label for unexplored cells
		remove_distance_label(cell)

func screen_to_global(screen_pos: Vector2, _camera: Camera2D) -> Vector2:
	# Get the viewport and its transformation
	var viewport = get_viewport()
	
	# Calculate the global position by applying the inverse of the canvas transform
	var canvas_transform = viewport.get_canvas_transform()
	var global_pos = canvas_transform.affine_inverse() * screen_pos
	
	return global_pos

# Calculate the distance between two hex grid cells using offset coordinates
func calculate_hex_distance(cell1: Vector2i, cell2: Vector2i) -> int:
	# Convert offset coordinates to axial coordinates
	# Godot uses odd-r offset by default for hexagonal tilemaps
	var q1 = cell1.x - (cell1.y - (cell1.y & 1)) / 2
	var r1 = cell1.y
	var q2 = cell2.x - (cell2.y - (cell2.y & 1)) / 2
	var r2 = cell2.y
	
	# Calculate distance using axial coordinates
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2

# Get tile ID based on distance from endgame (for background colors)
func get_tile_id_from_distance(distance: int) -> int:
	# Normalize distance
	var normalized_distance = min(distance, max_distance) / float(max_distance)
	
	if normalized_distance < 0.2:
		return 4  # Red - very close to endgame
	elif normalized_distance < 0.4:
		return 3  # Orange - close
	elif normalized_distance < 0.6:
		return 2  # Yellow - medium
	elif normalized_distance < 0.8:
		return 1  # Light blue - far
	else:
		return 0  # Dark blue - very far

func move_target_direction(direction: String) -> void:
	"""Move target with intuitive directional behavior"""
	var new_target:Vector2i
	if lock:
		return
	if target != null:
		var cell_options = get_surrounding_cells(ship_position).filter(func(x): return get_surrounding_cells(target).has(x))
		match direction:
			"down":
				new_target = cell_options.reduce(func(a, b): return a if a.y > b.y else b)
			"up":
				new_target = cell_options.reduce(func(a, b): return a if a.y < b.y else b)
			"right":
				new_target = cell_options.reduce(func(a, b): return a if a.x > b.x else b)
			"left":
				new_target = cell_options.reduce(func(a, b): return a if a.x < b.x else b)
	else:
		match direction:
			"down":
				new_target = Vector2i(ship_position.x, ship_position.y + 1)
			"up":
				new_target = Vector2i(ship_position.x, ship_position.y - 1)
			"right":
				new_target = Vector2i(ship_position.x + 1, ship_position.y)
			"left":
				new_target = Vector2i(ship_position.x - 1, ship_position.y)
	
	handle_cell_selection(new_target,true,true)


# Move ship to target cell and update game state
func move_to_target() -> void:
	if target != null:
		# Add current position to explored before moving
		if !explored.has(ship_position):
			explored.append(ship_position)
			# Update the SaveData reference
			SaveData.explored_tiles = explored
			
		# Move ship to new position
		set_ship_position(target)
		
		# Update explored cells to reveal background colors and ensure labels exist
		for cell in explored:
			if cell != ship_position:  # Don't override ship visual
				reset_cell(cell)
		
		# Check for endgame
		if ship_position == endgame:
			handle_endgame()
		
		# Reset target
		target = null

func _enter_tree() -> void:
	EventBus.subscribe('end_lvl',end_lvl)
	EventBus.subscribe('start_lvl',prepare_lvl)
	
func _exit_tree() -> void:
	EventBus.unsubscribe('end_lvl',end_lvl)
	EventBus.unsubscribe('start_lvl',prepare_lvl)
	# Clean up labels
	for label in tile_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	tile_labels.clear()

func end_lvl(success:bool):
	if success:
		lock = false
		move_to_target()
	else:
		handle_cell_selection(Vector2i(randi_range(0,9),randi_range(0,9)),true,true)
		EventBus.emit('start_lvl',true)
		
func prepare_lvl(punished:bool):
	lock = true

# Handle endgame logic
func handle_endgame() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://lvl/endgame.tscn")

# Optional: Regenerate background colors if endgame position changes
func set_endgame_position(new_endgame: Vector2i) -> void:
	endgame = new_endgame
	generate_background_colors()
	
	# Update all existing distance labels with new distances
	for cell in tile_labels.keys():
		update_distance_label(cell)

# Optional: Update a specific area of background colors (for performance)
func update_background_area(center: Vector2i, radius: int = 5) -> void:
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var cell = Vector2i(x, y)
			var distance = calculate_hex_distance(cell, endgame)
			var tile_id = get_tile_id_from_distance(distance)
			background_layer.set_cell(cell, 1, Vector2i(0, 0), tile_id)
			
			# Update distance label if it exists
			if tile_labels.has(cell):
				update_distance_label(cell)

# Get all valid target positions (for UI or AI purposes)
func get_valid_targets() -> Array:
	"""Return array of all valid target positions"""
	return get_surrounding_cells(ship_position)

# Cycle through valid targets
func cycle_target(forward: bool = true) -> void:
	"""Cycle through all valid target positions"""
	if lock:
		return
	
	var valid_targets = get_valid_targets()
	if valid_targets.size() == 0:
		return
	
	var current_index = 0
	if target != null and valid_targets.has(target):
		current_index = valid_targets.find(target)
	
	# Move to next/previous target
	if forward:
		current_index = (current_index + 1) % valid_targets.size()
	else:
		current_index = (current_index - 1 + valid_targets.size()) % valid_targets.size()
	
	var new_target = valid_targets[current_index]
	handle_cell_selection(new_target, true, true)

# Confirm current target selection
func confirm_target() -> void:
	"""Confirm the current target selection"""
	if lock:
		return
		
	if target != null:
		EventBus.emit('target_selected', target)
