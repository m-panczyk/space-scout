# player_data_module.gd
extends RefCounted
class_name PlayerDataModule

var weapon_name: String = 'basic'
var energy: int = 0
var energy_max: int = 10
var energy_production: Array = [1, 1]
var health: int = 10
var health_max: int = 10
var weapon_cost: int = 1

func reset_to_defaults() -> void:
	weapon_name = 'basic'
	energy = 0
	energy_max = 10
	energy_production = [1, 1]
	health = 1
	health_max = 1
	weapon_cost = 1

func to_dict() -> Dictionary:
	return {
		"weapon_name": weapon_name,
		"energy": energy,
		"energy_max": energy_max,
		"energy_production": energy_production,
		"health": health,
		"health_max": health_max,
		"weapon_cost": weapon_cost
	}

func from_dict(data: Dictionary) -> void:
	weapon_name = data.get("weapon_name", "basic")
	energy = data.get("energy", 0)
	energy_max = data.get("energy_max", 10)
	energy_production = data.get("energy_production", [1, 1])
	health = data.get("health", 1)
	health_max = data.get("health_max", 1)
	weapon_cost = data.get("weapon_cost", 1)

func _to_string() -> String:
	var output = ""
	output += "weapon_name: " + str(weapon_name) + "\n"
	output += "energy: " + str(energy) + "/" + str(energy_max) + "\n"
	output += "energy_production: " + str(energy_production) + "\n"
	output += "health: " + str(health) + "/" + str(health_max) + "\n"
	output += "weapon_cost: " + str(weapon_cost) + "\n"
	return output
