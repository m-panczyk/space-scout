extends Node

var is_new:bool = true

# Difficulty level (0 = Easy, 1 = Normal, 2 = Hard)
var difficulty_level:int = 1

var bg_type 
var bg_speed
var fall_speed

var points = 0
var explored_tiles = []
var ship_position = Vector2i(5,5)

var weapon_name = 'basic'
var energy = 0
var energy_max = 10
var energy_production = [1,1]

var health = 1
var health_max = 1

# Date when the save was created
var creation_date:String = ""
var save_date:String = ""

# Constants for save system
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"

func _ready():
	# Ensure the save directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func _to_string() -> String:
	var output = ""
	output += "is_new: " + str(is_new) + "\n"
	output += "difficulty_level: " + get_difficulty_name() + "\n"
	output += "bg_type: " + str(bg_type) + "\n"
	output += "bg_speed: " + str(bg_speed) + "\n"
	output += "fall_speed: " + str(fall_speed) + "\n"
	output += "points: " + str(points) + "\n"
	output += "explored_tiles: " + str(explored_tiles.size()) + " tiles\n"
	output += "ship_position: " + str(ship_position) + "\n"
	output += "weapon_name: " + str(weapon_name) + "\n"
	output += "energy: " + str(energy) + "/" + str(energy_max) + "\n"
	output += "energy_production: " + str(energy_production) + "\n"
	output += "creation_date: " + str(creation_date) + "\n"
	output += "save_date: " + str(save_date) + "\n"
	return output

# Helper function to get difficulty name from level
func get_difficulty_name() -> String:
	match difficulty_level:
		0: return "Easy"
		1: return "Normal"
		2: return "Hard"
		_: return "Unknown"

func show_as_detailed_popup():
	# Create a custom popup
	var popup = AcceptDialog.new()
	popup.title = "Save Data Details"
	
	# Create a rich text label for better formatting
	var rtl = RichTextLabel.new()
	rtl.bbcode_enabled = true
	
	# Format the text with bbcode
	var bbtext = "[b]Game Save Data[/b]\n\n"
	bbtext += "[color=#ffff00]is_new:[/color] " + str(is_new) + "\n"
	bbtext += "[color=#ffff00]difficulty_level:[/color] " + get_difficulty_name() + "\n"
	bbtext += "[color=#ffff00]bg_type:[/color] " + str(bg_type) + "\n"
	bbtext += "[color=#ffff00]bg_speed:[/color] " + str(bg_speed) + "\n"
	bbtext += "[color=#ffff00]fall_speed:[/color] " + str(fall_speed) + "\n"
	bbtext += "[color=#ffff00]points:[/color] " + str(points) + "\n"
	bbtext += "[color=#ffff00]explored_tiles:[/color] " + str(explored_tiles.size()) + " tiles\n"
	bbtext += "[color=#ffff00]ship_position:[/color] " + str(ship_position) + "\n"
	bbtext += "[color=#ffff00]weapon_name:[/color] " + str(weapon_name) + "\n"
	bbtext += "[color=#ffff00]energy:[/color] " + str(energy) + "/" + str(energy_max) + "\n"
	bbtext += "[color=#ffff00]energy_production:[/color] " + str(energy_production) + "\n"
	bbtext += "[color=#ffff00]creation_date:[/color] " + str(creation_date) + "\n"
	bbtext += "[color=#ffff00]save_date:[/color] " + str(save_date)
	
	rtl.text = bbtext
	rtl.custom_minimum_size = Vector2(400, 300)
	
	# Add the rich text label to the popup
	popup.add_child(rtl)
	
	# Add it to the scene tree temporarily
	var root = get_tree().root
	root.add_child(popup)
	
	# Center the popup on screen
	popup.popup_centered()
	
	# Connect the close signal to remove the popup when closed
	popup.connect("confirmed", func(): popup.queue_free())
	popup.connect("close_requested", func(): popup.queue_free())

# Saves the current game state to a file
func save_game(save_name: String) -> void:
	# Create a save directory with timestamp
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		datetime["year"], 
		datetime["month"], 
		datetime["day"],
		datetime["hour"], 
		datetime["minute"], 
		datetime["second"]
	]
	
	# Set creation date if it's a new save
	if creation_date == "":
		creation_date = timestamp
	save_date = timestamp
	var save_path = SAVE_DIR + save_name + SAVE_EXTENSION
	
	# Convert explored_tiles Vector2i objects to a serializable format
	var serialized_tiles = []
	for tile in explored_tiles:
		if tile is Vector2i:
			serialized_tiles.append({
				"x": tile.x,
				"y": tile.y
			})
		else:
			# Handle case where tile might not be Vector2i
			push_error("Unexpected type in explored_tiles: " + str(typeof(tile)))
	
	# Create the save data dictionary
	var save_data = {
		"is_new": is_new,
		"difficulty_level": difficulty_level,
		"bg_type": bg_type,
		"bg_speed": bg_speed,
		"fall_speed": fall_speed,
		"points": points,
		"explored_tiles": serialized_tiles,
		"ship_position": {
			"x": ship_position.x,
			"y": ship_position.y
		},
		"weapon_name": weapon_name,
		"energy": energy,
		"energy_max": energy_max,
		"energy_production": energy_production,
		"health": health,
		"health_max": health_max,
		"save_name": save_name,
		"creation_date": creation_date,
		"save_date": save_date
	}
	
	# Open the file for writing
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		# Convert the save data to JSON and write it to the file
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		print("Game saved successfully to: " + save_path)
	else:
		push_error("Failed to open save file for writing: " + save_path)

# Loads a game from a specific save file path
func load_game(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("Save file does not exist: " + file_path)
		return false
	
	# Open the file for reading
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: " + file_path)
		return false
	
	# Read the JSON string from the file
	var json_string = file.get_as_text()
	
	# Parse the JSON string
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse save file JSON: " + file_path)
		return false
	
	var save_data = json.get_data()
	
	# Load the save data into the game state
	is_new = save_data.get("is_new", true)
	difficulty_level = save_data.get("difficulty_level", 1)  # Default to Normal if not found
	bg_type = save_data.get("bg_type", null)
	bg_speed = save_data.get("bg_speed", null)
	fall_speed = save_data.get("fall_speed", null)
	points = save_data.get("points", 0)
	
	# Handle explored_tiles properly - convert to Vector2i objects
	var raw_explored_tiles = save_data.get("explored_tiles", [])
	explored_tiles = []
	for tile in raw_explored_tiles:
		if tile is Dictionary and tile.has("x") and tile.has("y"):
			# If tile is stored as {x: val, y: val}
			explored_tiles.append(Vector2i(tile.x, tile.y))
		elif tile is Array and tile.size() == 2:
			# If tile is stored as [x, y]
			explored_tiles.append(Vector2i(tile[0], tile[1]))
		elif tile is String:
			# If tile is stored as "x,y"
			var parts = tile.split(",")
			if parts.size() == 2:
				explored_tiles.append(Vector2i(int(parts[0]), int(parts[1])))
	
	# Convert ship position from dictionary back to Vector2i
	var pos_dict = save_data.get("ship_position", {"x": 5, "y": 5})
	ship_position = Vector2i(pos_dict.get("x", 5), pos_dict.get("y", 5))
	
	weapon_name = save_data.get("weapon_name", "basic")
	energy = save_data.get("energy", 0)
	energy_max = save_data.get("energy_max", 10)
	energy_production = save_data.get("energy_production", [1, 1])
	health = save_data.get("health", 1)
	health_max = save_data.get("health_max", 1)
	creation_date = save_data.get("creation_date", "")
	save_date = save_data.get("save_date", "")
	
	print("Game loaded successfully from: " + file_path)
	return true

# Loads the most recent save file
func load_latest_save() -> bool:
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		push_error("Failed to open saves directory")
		return false
	
	var save_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	# Collect all save files
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
			save_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if save_files.size() == 0:
		push_error("No save files found")
		return false
	
	# Sort save files to find the most recent one
	# Since we use timestamp in filename, alphabetical sorting will work
	save_files.sort()
	save_files.reverse() # Most recent first
	
	# Load the most recent save file
	return load_game(SAVE_DIR + save_files[0])

# Get a list of all save files with their details including difficulty level
func get_all_save_files() -> Array:
	var save_list = []
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		push_error("Failed to open saves directory")
		return save_list
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	# Collect all save files with their details
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
			var file_path = SAVE_DIR + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json_string = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_string)
				if error == OK:
					var save_data = json.get_data()
					var difficulty = save_data.get("difficulty_level", 1) # Default to Normal
					var difficulty_name = "Normal"
					
					# Convert difficulty level to readable name
					match difficulty:
						0: difficulty_name = "Easy"
						1: difficulty_name = "Normal"
						2: difficulty_name = "Hard"
					
					save_list.append({
						"path": file_path,
						"filename": file_name,
						"save_name": save_data.get("save_name", "Unknown"),
						"points": save_data.get("points", 0),
						"difficulty_level": difficulty,
						"difficulty_name": difficulty_name,
						"creation_date": save_data.get("creation_date", save_data.get("save_datetime", "Unknown")),
						"save_date": save_data.get("save_date", save_data.get("save_datetime", "Unknown"))
					})
			file_name = dir.get_next()
	dir.list_dir_end()
	save_list.sort_custom(func(a, b): return a["save_date"] > b["save_date"])
	
	return save_list

# Show a save dialog that prompts the user for a save name
# This dialog works when the game is paused
func show_save_dialog() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Save Game"
	
	# Make the dialog process even when game is paused
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(300, 150)
	
	var name_label = Label.new()
	name_label.text = "Enter a name for your save:"
	
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = "My Save Game"
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var difficulty_label = Label.new()
	difficulty_label.text = "Select difficulty level:"
	difficulty_label.position.y += 10
	
	var difficulty_option = OptionButton.new()
	difficulty_option.add_item("Easy", 0)
	difficulty_option.add_item("Normal", 1)
	difficulty_option.add_item("Hard", 2)
	difficulty_option.selected = difficulty_level
	difficulty_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	vbox.add_child(name_label)
	vbox.add_child(line_edit)
	vbox.add_child(difficulty_label)
	vbox.add_child(difficulty_option)
	
	dialog.add_child(vbox)
	dialog.add_button("Save", true, "save")
	dialog.add_button("Cancel", false, "cancel")
	
	# Store current pause state to restore it later if needed
	var was_paused = get_tree().paused
	
	# Add dialog to the scene
	var root = get_tree().root
	root.add_child(dialog)
	
	# Make sure the dialog stays on top
	dialog.exclusive = true
	
	# Center the dialog
	dialog.popup_centered()
	
	# Focus the line edit for immediate typing
	line_edit.call_deferred("grab_focus")
	
	# Common cleanup function for all exit paths
	var cleanup_func = func():
		dialog.queue_free()
		# Only restore pause state if it was previously paused
		# This prevents unpausing a game that was intentionally paused
		if was_paused:
			get_tree().paused = was_paused
	
	# Connect signals
	dialog.connect("confirmed", func():
		var save_name = line_edit.text
		if save_name.strip_edges() == "":
			save_name = "My Save Game"
		difficulty_level = difficulty_option.get_selected_id()
		save_game(save_name)
		cleanup_func.call()
	)
	
	dialog.connect("custom_action", func(action):
		if action == "save":
			var save_name = line_edit.text
			if save_name.strip_edges() == "":
				save_name = "My Save Game"
			difficulty_level = difficulty_option.get_selected_id()
			save_game(save_name)
		cleanup_func.call()
	)
	
	dialog.connect("canceled", func():
		cleanup_func.call()
	)
	
	# Connect close requested signal to handle Escape key or close button
	dialog.connect("close_requested", func():
		cleanup_func.call()
	)
