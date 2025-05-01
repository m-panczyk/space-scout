extends Control

const threshold := 5000
var pressedPos : Vector2
var releasePos : Vector2


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_double_tap():
			pass

	if event.is_action("ui_left"):
		$TextureRect.flip_h = true
	elif event.is_action("ui_right"):
		$TextureRect.flip_h = false

	if event.is_action("ui_up"):
		$TextureRect.flip_v = true
	elif event.is_action("ui_down"):
		$TextureRect.flip_v = false
	$Label.text = event.as_text()
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
