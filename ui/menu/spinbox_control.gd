extends SpinBox

func _input(event):
	if has_focus():
		print("has focus")
		if event.is_action_pressed("ui_up"):
			value += step
		elif event.is_action_pressed("ui_down"):
			value -= step

func _on_focus_entered():
	print("focus enter")
	modulate = Color(1, 1, 1, 1)  # Ensure full opacity
	# Quick visual feedback
	create_tween().tween_property(self, "modulate", Color.CYAN, 0.1)

func _on_focus_exited():
	print("focus exited")
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)
