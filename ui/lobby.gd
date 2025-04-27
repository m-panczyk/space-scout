extends Control
class_name Lobby

signal start_game(player_config, level_config)

# Default configurations
var player_config = {
	"weapon_name": "basic",
	"energy": 5,
	"energy_max": 10,
	"energy_production": [1, 1],
	"health": 3,
	"max_health": 3,
	"speed": 400,
	"skin_path": "res://actors/player/img/base_0.tscn"
}

var level_config = {
	"bg_type": "0",
	"bg_speed": 0.1,
	"fall_speed": 100,
	"difficulty": 1.0
}

# UI References
var ui_container: Control
var player_preview: TextureRect
var start_button: Button
var weapon_options: OptionButton
var available_weapons = ["basic", "laser", "spread"]  # Add more as needed

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	setup_ui()
	load_saved_configs()
	update_preview()

# Setup the UI elements
func setup_ui() -> void:
	ui_container = Control.new()
	add_child(ui_container)
	ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)

	
	# Create main panel
	var panel = Panel.new()
	ui_container.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(600, 400)

	
	# Create VBox container for layout
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Use proper margins in Godot 4
	var margin = 20
	vbox.position = Vector2(margin, margin)
	vbox.size = panel.size - Vector2(margin * 2, margin * 2)

	
	# Title
	var title = Label.new()
	vbox.add_child(title)
	title.text = "Game Configuration"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.custom_minimum_size.y = 40

	
	# Create tabbed container
	var tabs = TabContainer.new()
	vbox.add_child(tabs)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	
	# Player settings tab
	var player_tab = Control.new()
	tabs.add_child(player_tab)
	tabs.set_tab_title(0, "Player")
	create_player_tab(player_tab)

	
	# Level settings tab
	var level_tab = Control.new()
	tabs.add_child(level_tab)
	tabs.set_tab_title(1, "Level")
	create_level_tab(level_tab)
	# Start button
	start_button = Button.new()
	vbox.add_child(start_button)
	start_button.text = "Start Game"
	start_button.custom_minimum_size.y = 50

	start_button.pressed.connect(_on_start_button_pressed)

# Create player configuration tab
func create_player_tab(tab:Control):

	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Use proper margins in Godot 4
	var margin = 10
	hbox.position = Vector2(margin, margin)
	hbox.size = tab.size - Vector2(margin * 2, margin * 2)
	tab.add_child(hbox)
	
	# Left side - Settings
	var settings_vbox = VBoxContainer.new()
	settings_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_vbox.size_flags_stretch_ratio = 0.6
	hbox.add_child(settings_vbox)
	
	# Weapon selection
	var weapon_hbox = HBoxContainer.new()
	settings_vbox.add_child(weapon_hbox)
	
	var weapon_label = Label.new()
	weapon_label.text = "Weapon:"
	weapon_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weapon_label.size_flags_stretch_ratio = 0.4
	weapon_hbox.add_child(weapon_label)
	
	weapon_options = OptionButton.new()
	weapon_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weapon_options.size_flags_stretch_ratio = 0.6
	for weapon in available_weapons:
		weapon_options.add_item(weapon)
	weapon_options.selected = available_weapons.find(player_config.weapon_name)
	weapon_options.item_selected.connect(_on_weapon_selected)
	weapon_hbox.add_child(weapon_options)
	
	# Health slider
	add_slider_setting(settings_vbox, "Health:", 1, 10, player_config.health, _on_health_changed)
	
	# Energy slider
	add_slider_setting(settings_vbox, "Starting Energy:", 1, player_config.energy_max, player_config.energy, _on_energy_changed)
	
	# Max Energy slider
	add_slider_setting(settings_vbox, "Max Energy:", 5, 20, player_config.energy_max, _on_max_energy_changed)
	
	# Energy Production Rate
	add_slider_setting(settings_vbox, "Energy Production:", 1, 5, player_config.energy_production[0], _on_energy_production_changed)
	
	# Energy Production Interval
	add_slider_setting(settings_vbox, "Production Interval:", 0.5, 3.0, player_config.energy_production[1], _on_production_interval_changed, 0.1)
	
	# Speed slider
	add_slider_setting(settings_vbox, "Speed:", 200, 600, player_config.speed, _on_speed_changed)
	
	# Right side - Preview
	var preview_vbox = VBoxContainer.new()
	preview_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_vbox.size_flags_stretch_ratio = 0.4
	hbox.add_child(preview_vbox)
	
	var preview_label = Label.new()
	preview_label.text = "Player Preview"
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_vbox.add_child(preview_label)
	
	player_preview = TextureRect.new()
	player_preview.expand = true
	player_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	player_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_vbox.add_child(player_preview)


# Create level configuration tab
func create_level_tab(tab:Control) -> void:
	
	var vbox = VBoxContainer.new()
	tab.add_child(vbox)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Use proper margins in Godot 4
	var margin = 10
	vbox.position = Vector2(margin, margin)
	vbox.size = tab.size - Vector2(margin * 2, margin * 2)

	
	# Background type
	var bg_hbox = HBoxContainer.new()
	vbox.add_child(bg_hbox)
	
	var bg_label = Label.new()
	bg_hbox.add_child(bg_label)
	bg_label.text = "Background Type:"
	bg_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_label.size_flags_stretch_ratio = 0.4
	
	
	var bg_options = OptionButton.new()
	bg_hbox.add_child(bg_options)
	bg_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_options.size_flags_stretch_ratio = 0.6
	bg_options.add_item("Space", 0)
	bg_options.add_item("Ocean", 1)
	bg_options.add_item("Forest", 2)
	bg_options.selected = int(level_config.bg_type)
	bg_options.item_selected.connect(_on_bg_type_selected)
	
	
	# Background speed
	add_slider_setting(vbox, "Background Speed:", 0.05, 0.5, level_config.bg_speed, _on_bg_speed_changed, 0.01)
	
	# Fall speed
	add_slider_setting(vbox, "Fall Speed:", 50, 300, level_config.fall_speed, _on_fall_speed_changed)
	
	# Difficulty
	add_slider_setting(vbox, "Starting Difficulty:", 0.5, 2.0, level_config.difficulty, _on_difficulty_changed, 0.1)


# Helper function to add slider settings
func add_slider_setting(parent: Control, label_text: String, min_value: float, max_value: float, 
						current_value: float, callback: Callable, step: float = 1.0) -> HSlider:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 0.4
	container.add_child(label)
	
	var slider_container = HBoxContainer.new()
	slider_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_container.size_flags_stretch_ratio = 0.6
	container.add_child(slider_container)
	
	var slider = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = current_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_stretch_ratio = 0.7
	slider_container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(current_value)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.size_flags_stretch_ratio = 0.3
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slider_container.add_child(value_label)
	
	# Connect value changed signal
	slider.value_changed.connect(
		func(value): 
			value_label.text = str(value if step == 1.0 else snappedf(value, step))
			callback.call(value)
	)
	
	return slider

# Update player preview based on config
func update_preview() -> void:
	# In a real implementation, you'd load the actual sprite or scene
	# For now, we'll just update the texture when this is implemented
	# This is a placeholder for where you'd load and display the player preview
	print("Player config updated: ", player_config)

# Save the configurations to be used later
func save_configs() -> void:
	# In a real implementation, you might want to save these to user://
	print("Saving configurations")
	# Example:
	# var save_file = FileAccess.open("user://player_config.dat", FileAccess.WRITE)
	# save_file.store_var(player_config)
	# save_file.close()

# Load saved configurations
func load_saved_configs() -> void:
	# In a real implementation, you might want to load these from user://
	print("Loading configurations")
	# Example:
	# if FileAccess.file_exists("user://player_config.dat"):
	#    var save_file = FileAccess.open("user://player_config.dat", FileAccess.READ)
	#    player_config = save_file.get_var()
	#    save_file.close()

# Callback functions for UI interactions
func _on_weapon_selected(index: int) -> void:
	player_config.weapon_name = available_weapons[index]
	update_preview()

func _on_health_changed(value: float) -> void:
	player_config.health = int(value)
	player_config.max_health = int(value)

func _on_energy_changed(value: float) -> void:
	player_config.energy = int(value)

func _on_max_energy_changed(value: float) -> void:
	player_config.energy_max = int(value)
	# Ensure current energy doesn't exceed max
	player_config.energy = min(player_config.energy, player_config.energy_max)

func _on_energy_production_changed(value: float) -> void:
	player_config.energy_production[0] = int(value)

func _on_production_interval_changed(value: float) -> void:
	player_config.energy_production[1] = value

func _on_speed_changed(value: float) -> void:
	player_config.speed = int(value)

func _on_bg_type_selected(index: int) -> void:
	level_config.bg_type = str(index)

func _on_bg_speed_changed(value: float) -> void:
	level_config.bg_speed = value

func _on_fall_speed_changed(value: float) -> void:
	level_config.fall_speed = int(value)

func _on_difficulty_changed(value: float) -> void:
	level_config.difficulty = value

# Start the game with the configured settings
func _on_start_button_pressed() -> void:
	save_configs()
	emit_signal("start_game", player_config, level_config)

# Public method to show the lobby
func show_lobby() -> void:
	ui_container.visible = true

# Public method to hide the lobby
func hide_lobby() -> void:
	ui_container.visible = false

# Public method to create and start a new game level
func create_game_level() -> GameLevel:
	var new_player = create_player_from_config()
	var new_level = GameLevel.new(new_player)
	
	# Set level properties
	new_level.bg_type = level_config.bg_type
	new_level.bg_speed = level_config.bg_speed
	new_level.fall_speed = level_config.fall_speed
	
	# Configure EnvGenerator difficulty when level is ready
	new_level.ready.connect(
		func():
			if new_level.has_node("EnvGenerator"):
				var env_gen = new_level.get_node("EnvGenerator")
				env_gen.pace_level_start = level_config.difficulty
	)
	
	return new_level

# Helper method to create player from config
func create_player_from_config() -> Player:
	var new_player = Player.new()
	
	# Set player properties from config
	new_player.weapon_name = player_config.weapon_name
	new_player.energy = player_config.energy
	new_player.energy_max = player_config.energy_max
	new_player.energy_production = player_config.energy_production
	new_player.health = player_config.health
	new_player.max_health = player_config.max_health
	new_player.speed = player_config.speed
	new_player.skin_path = player_config.skin_path
	
	return new_player
