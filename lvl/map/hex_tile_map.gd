extends TileMapLayer

var _ship_position = SaveData.ship_position
var ship_position:
	get:
		return _ship_position
	set(value):
		_ship_position = value
		SaveData.ship_position = value
var target = null
var last_pressed = null
var endgame = Vector2i(0, 0)
var _explored = SaveData.explored_tiles
var explored:
	get:
		return _explored
	set(value):
		_explored = value
		SaveData.explored = value
var max_distance = 10  # Maximum possible distance for color gradient calculation
var lock = false

func _ready() -> void:
	for cell in explored:
		reset_cell(cell)
	set_ship_position(ship_position)
	
func _input(event: InputEvent) -> void:
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

func set_ship_position(new_ship_position: Vector2i = Vector2i(5, 5)) -> void:
	print(str(SaveData))
	reset_cell(ship_position)
	ship_position = new_ship_position
	set_cell(ship_position, 3, Vector2i(0, 0))  # Set ship visual
	
	# Update surrounding cells
	#for cell in get_surrounding_cells(ship_position):
		#if !explored.has(cell):
			## Color tile based on distance to endgame
			#var distance = calculate_hex_distance(cell, endgame)
			#var tile_id = get_tile_id_from_distance(distance)
			#set_cell(cell, 2, Vector2i(0, 0), tile_id)
			
	# Update camera position
	%Camera2D.position = map_to_local(ship_position)

func reset_cell(cell: Vector2i) -> void:
	if explored.has(cell):
		var distance = calculate_hex_distance(cell, endgame)
		var tile_id = get_tile_id_from_distance(distance)
		set_cell(cell, 2, Vector2i(0, 0), tile_id)
	else:
		set_cell(cell,0,Vector2i.ZERO,0)

func screen_to_global(screen_pos: Vector2, _camera: Camera2D) -> Vector2:
	# Get the viewport and its transformation
	var viewport = get_viewport()
	
	# Calculate the global position by applying the inverse of the canvas transform
	var canvas_transform = viewport.get_canvas_transform()
	var global_pos = canvas_transform.affine_inverse() * screen_pos
	
	return global_pos

# Calculate the distance between two hex grid cells
func calculate_hex_distance(cell1: Vector2i, cell2: Vector2i) -> int:
	# Using cube coordinates for hex distance calculation
	# Convert axial to cube coordinates
	var x1 = cell1.x
	var z1 = cell1.y
	var y1 = -x1 - z1
	var x2 = cell2.x
	var z2 = cell2.y
	var y2 = -x2 - z2
	
	# Calculate distance in cube coordinates
	return (abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)) / 2

# Get tile ID based on distance from endgame
func get_tile_id_from_distance(distance: int) -> int:
	# Normalize distance
	var normalized_distance = min(distance, max_distance) / float(max_distance)
	
	if normalized_distance < 0.2:
		return 4
	elif normalized_distance < 0.4:
		return 3
	elif normalized_distance < 0.6:
		return 2
	elif normalized_distance < 0.8:
		return 1
	else:
		return 0

# Move ship to target cell and update game state
func move_to_target() -> void:
	if target != null:
		# Add current position to explored
		if !explored.has(ship_position):
			explored.append(ship_position)
			
		# Move ship to new position
		set_ship_position(target)
		
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

func end_lvl(success:bool):
	if success:
		lock = false
		move_to_target()
		#$"../..".material.set_shader_parameter("enabled",false)
	else:
		handle_cell_selection(Vector2i(randi_range(0,9),randi_range(0,9)),true,true)
		EventBus.emit('start_lvl',true)
func prepare_lvl(punished:bool):
	lock = true
	#if punished:
		#$"../..".material.set_shader_parameter("enabled",true)
# Handle endgame logic
func handle_endgame() -> void:
	EventBus.emit('end_game',true)
