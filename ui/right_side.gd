extends TextureRect

func _ready() -> void:
	_on_resized()

func _on_right_hide_pressed() -> void:
	hide()
	%HUD.show()


func _on_resized() -> void:
	if !($"..".portrait_mode):
		$RightHide.hide()
