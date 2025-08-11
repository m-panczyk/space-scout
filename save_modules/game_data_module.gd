# game_data_module.gd
extends RefCounted
class_name GameDataModule

var is_new: bool = true
var bg_type = null
var bg_speed = null
var fall_speed = null
var points: int = 0
var explored_tiles: Array = []
var endgame: Vector2i = Vector2i(0,0)
var ship_position: Vector2i = Vector2i(5, 5)
var job_value: int = 30

func reset_to_defaults() -> void:
	is_new = true
	bg_type = null
	bg_speed = null
	fall_speed = null
	points = 0
	explored_tiles = []
	endgame = Vector2i(0,0)
	ship_position = Vector2i(5, 5)
	job_value = 30

func to_dict() -> Dictionary:
	var serialized_tiles = []
	for tile in explored_tiles:
		if tile is Vector2i:
			serialized_tiles.append({
				"x": tile.x,
				"y": tile.y
			})
		else:
			push_error("Unexpected type in explored_tiles: " + str(typeof(tile)))
	
	return {
		"is_new": is_new,
		"bg_type": bg_type,
		"bg_speed": bg_speed,
		"fall_speed": fall_speed,
		"points": points,
		"explored_tiles": serialized_tiles,
		"endgame": {
			"x": endgame.x,
			"y": endgame.y
		},
		"ship_position": {
			"x": ship_position.x,
			"y": ship_position.y
		},
		"job_value": job_value
	}

func from_dict(data: Dictionary) -> void:
	is_new = data.get("is_new", true)
	bg_type = data.get("bg_type", null)
	bg_speed = data.get("bg_speed", null)
	fall_speed = data.get("fall_speed", null)
	points = data.get("points", 0)
	job_value = data.get("job_value", 0)
	
	# Handle explored_tiles properly
	var raw_explored_tiles = data.get("explored_tiles", [])
	explored_tiles = []
	for tile in raw_explored_tiles:
		if tile is Dictionary and tile.has("x") and tile.has("y"):
			explored_tiles.append(Vector2i(tile.x, tile.y))
		elif tile is Array and tile.size() == 2:
			explored_tiles.append(Vector2i(tile[0], tile[1]))
		elif tile is String:
			var parts = tile.split(",")
			if parts.size() == 2:
				explored_tiles.append(Vector2i(int(parts[0]), int(parts[1])))
	
	var end_pos = data.get("endgame", {"x": 0, "y": 0})
	endgame = Vector2i(end_pos.get("x", 0), end_pos.get("y", 0))
	var pos_dict = data.get("ship_position", {"x": 5, "y": 5})
	ship_position = Vector2i(pos_dict.get("x", 5), pos_dict.get("y", 5))

func _to_string() -> String:
	var output = ""
	output += "is_new: " + str(is_new) + "\n"
	output += "bg_type: " + str(bg_type) + "\n"
	output += "bg_speed: " + str(bg_speed) + "\n"
	output += "fall_speed: " + str(fall_speed) + "\n"
	output += "points: " + str(points) + "\n"
	output += "explored_tiles: " + str(explored_tiles.size()) + " tiles\n"
	output += "endgame: " + str(endgame) + "\n"
	output += "ship_position: " + str(ship_position) + "\n"
	output += "job_value: " + str(job_value) + "\n"
	return output
