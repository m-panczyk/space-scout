extends Node
class_name UpgradeManager

@export var player:Player

func _ready():
	# Subscribe to all upgrade events
	EventBus.subscribe("upgrade_hull", upgrade_hull)
	EventBus.subscribe("upgrade_energy_max", upgrade_energy_max)
	EventBus.subscribe("upgrade_energy_production", upgrade_energy_production)
	EventBus.subscribe("upgrade_speed", upgrade_speed)
	EventBus.subscribe("upgrade_weapon_efficiency", upgrade_weapon_efficiency)
func _exit_tree():
	# Unsubscribe from all events
	EventBus.unsubscribe("upgrade_hull", upgrade_hull)
	EventBus.unsubscribe("upgrade_energy_max", upgrade_energy_max)
	EventBus.unsubscribe("upgrade_energy_production", upgrade_energy_production)
	EventBus.unsubscribe("upgrade_speed", upgrade_speed)
	EventBus.unsubscribe("upgrade_weapon_efficiency", upgrade_weapon_efficiency)

func upgrade_hull(amount):
	if player.health >= player.max_health:
		player.max_health += amount
	player.health += amount
	player.health_changed()

func upgrade_energy_max(amount):
	player.energy_max += amount

func upgrade_energy_production(amount):
	player.energy_production[0] += amount

func upgrade_speed(amount):
	player.speed += amount

func upgrade_weapon_efficiency(amount):
	if player.weapon_cost > 2:
		player.weapon_cost -= amount
