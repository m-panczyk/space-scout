extends NinePatchRect

func pass_focus():
	$Lab/Jobs/Hull/Button.grab_focus()


func _on_focus_entered() -> void:
	print("LP gained focus")
	pass_focus()


func _on_focus_exited() -> void:
	print("LP lost focus")
