extends Control

const threshold := 5000
var pressedPos : Vector2
var releasePos : Vector2


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		$TextureRect.set_visible(!$TextureRect.is_visible())
	if Input.is_action_just_pressed("click"):
		pressedPos = event.position
		print(pressedPos)
	if Input.is_action_just_released("click"):
		releasePos = event.position
		print(releasePos)
		calculateGesture()


func calculateGesture() -> void:
	var d := releasePos - pressedPos
	if d.length_squared() > threshold: 
		print(d)
		if abs(d.x) > abs(d.y):
			print("left or right")
			if d.x < 0:
				print("left")
			else:
				print("right")
		else:
			print("up or down")
			if d.y > 0:
				print("down")
			else:
				print("up")
