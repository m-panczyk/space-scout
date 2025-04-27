extends Node2D
class_name Weapon

@export var speed:int = 400
@export var consumption:int = 1
@export var bullet = preload("res://actors/bullets/basic.tscn")
@export var sprite_name = ""

func _ready() -> void:
	if sprite_name != "":
		var sprite = load("res://actors/weapons/img/"+sprite_name+".tscn").\
			instatiate()
		add_child(sprite)
		
		
func fire() -> void:
	var new_bullet = bullet.instantiate()
	new_bullet.speed = speed
	new_bullet.position = get_parent().position
	new_bullet.scale = get_parent().scale
	get_parent().get_parent().add_child(new_bullet)
