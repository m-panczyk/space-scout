extends Control
@onready var player = get_tree().get_first_node_in_group("PLAYER") 

func _ready() -> void:
	GlobalSettings.set_touch_controls(GlobalSettings.TouchControlType.POINT)
	player.move_target_reached.connect(_on_player_target_reached, CONNECT_ONE_SHOT)
	player.weapon_fired.connect(_on_player_weapon_fired, CONNECT_ONE_SHOT)

func _on_player_target_reached(_target_pos: Vector2):
	$move.hide()
	$game_fire.show()
	$Command.text = "Test systemów bojowych"
	
	
func _on_player_weapon_fired(weapon_name: String, energy_consumed: int):
	$game_fire.hide()
	queue_free()
