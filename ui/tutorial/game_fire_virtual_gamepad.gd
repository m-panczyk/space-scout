extends Label

func _ready() -> void:
	GlobalSettings.set_touch_controls(GlobalSettings.TouchControlType.JOYPAD_TOUCH)

func _on_visibility_changed() -> void:
	if visible:
		get_tree().get_first_node_in_group("PLAYER").weapon_fired.connect(_on_weapon_fired,CONNECT_ONE_SHOT)
		
func _on_weapon_fired(_weapon_name,_energy_consume):
	get_parent().queue_free()
