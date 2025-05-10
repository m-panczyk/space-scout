extends Node

# Array to store tile data
var tile_data = []

# Called when the node enters the scene tree
func _ready():
	# Initialize default data
	initialize_default_data()
	
# Initialize default tile data
func initialize_default_data():
	tile_data = []
	
	# Example: Create data for a triangle of height 10
	# This will create 55 tiles (sum of 1 to 10)
	var total_tiles = (10 * 11) / 2
	
	# Create data for each tile
	for i in range(total_tiles):
		var data = {
			"id": i,
			"type": "normal",
			"state": "default",
			"value": randi() % 100  # Some random value for demonstration
		}
		
		# Make some tiles special
		if i % 7 == 0:  # Every 7th tile is special
			data["type"] = "special"
		
		tile_data.append(data)

# Get all tile data
func get_tile_data():
	return tile_data

# Get data for a specific tile
func get_tile_data_at(index):
	if index >= 0 and index < tile_data.size():
		return tile_data[index]
	return null

# Update data for a specific tile
func update_tile_data(index, new_data):
	if index >= 0 and index < tile_data.size():
		# Update only the specified fields
		for key in new_data:
			tile_data[index][key] = new_data[key]
		
		# Emit signal that data changed
		data_changed.emit(index, tile_data[index])

# Signal emitted when tile data changes
signal data_changed(index, data)

# Load data from external source (e.g., a file or server)
func load_data_from_external(data_source):
	# Implementation depends on your game's data structure
	# For example, loading from a JSON file:
	
	# var file = FileAccess.open(data_source, FileAccess.READ)
	# if file:
	#     var json_string = file.get_as_text()
	#     var json = JSON.parse_string(json_string)
	#     if json:
	#         tile_data = json
	#     file.close()
	pass

# Save data to external source
func save_data_to_external(data_destination):
	# Implementation depends on your game's needs
	# For example, saving to a JSON file:
	
	# var file = FileAccess.open(data_destination, FileAccess.WRITE)
	# if file:
	#     var json_string = JSON.stringify(tile_data)
	#     file.store_string(json_string)
	#     file.close()
	pass
