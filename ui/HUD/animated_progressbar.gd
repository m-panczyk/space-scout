extends TextureRect
@export var value = 100: set = set_value
var step = 5
var atlas_step = 64
var max_value = 1
	
@export var data_type = 'health'
var label: Label

func set_value(new_value):
	# Clip value to range 0-max_value
	new_value = clamp(new_value, 0, max_value)
	
	# Only update if value actually changed
	if new_value != value:
		value = new_value
		update_atlas_region()

func update_atlas_region():
	# Calculate percentage of current value relative to max_value
	var percentage = (value / float(max_value)) * 100.0
	
	# Calculate atlas steps using integer division to avoid floating point issues
	# Round to nearest step first, then calculate atlas steps
	var rounded_percentage = round(percentage / step) * step
	var atlas_steps = (100 - rounded_percentage) / step
	
	# Get current atlas region or create default if none exists
	var current_region = texture.region
	if current_region == Rect2():
		current_region = Rect2(0, 0, texture.get_width(), texture.get_height())
	
	# Update y position based on atlas steps (now guaranteed to be integer)
	current_region.position.y = int(atlas_steps) * atlas_step
	
	# Apply the updated region
	texture.region = current_region

func _enter_tree() -> void:
	EventBus.subscribe(data_type + "_changed", _on_data_changed)

func _ready() -> void:
	value = SaveData.get(data_type)
	max_value = SaveData.get(str(data_type, "_max"))
	_on_data_changed([value, max_value])

func _on_data_changed(data: Array):
	max_value = data[1]
	value = data[0]
	
	$Label.text = tr("GAME_CHARACTER_" + data_type.to_upper()) + " " + str(int(value)) + "/" + str(int(max_value))

func _exit_tree() -> void:
	EventBus.unsubscribe(data_type + "_changed", _on_data_changed)
