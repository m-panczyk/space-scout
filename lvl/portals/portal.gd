extends Area2D

@export var answer = 0
var fall:bool = false
var direction = Vector2.DOWN
var speed = 100

func _process(delta: float) -> void:
	if fall:
		var velocity = direction.normalized() * speed
		position += velocity * delta

func show_question():
	show()
	$CollisionShape2D.disabled = false
	fall = true

func hide_question():
	fall = false
	hide()
	$CollisionShape2D.disabled = true
	position.y = 0
	

func _ready() -> void:
	area_entered.connect(got_answer)
func got_answer(other_area):
	if other_area is Player:
		EventBus.emit("end_lvl",GlobalSettings.is_correct_answer(answer))
		get_tree().call_group('PORTALS','hide_question')
