extends GridContainer
var player: Player
var weapon_name

func _ready() -> void:
	find_player()
	EventBus.subscribe("stats_update",update_values)

func _exit_tree() -> void:
	EventBus.unsubscribe("stats_update",update_values)
func find_player() -> void:
	player = get_tree().get_first_node_in_group("PLAYER")
	if player:
		update_values()
	else:
		# Retry on the next frame
		call_deferred("find_player")
	
func update_values(_arg=null) -> void:
	$NameVale.text = player.weapon_name
	$EnergyValue.text = str(player.weapon.consumption)
	$DamageValue.text = str(player.weapon.damage)
