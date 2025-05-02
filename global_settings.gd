extends Node

var virtual_resolution:Vector2 = Vector2(1080,1920)
var language = 0
const LANGUAGE = ['pl','en','de']

func _ready() -> void:
	print("loading global settings")
