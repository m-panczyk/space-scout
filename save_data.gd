extends Node

var is_new:bool = true

var bg_type 
var bg_speed
var fall_speed

var points = 0
var explored_tiles = []

func _to_string() -> String:
	return str("Pts: ", points, "\n Długość podróży:",explored_tiles.size())
