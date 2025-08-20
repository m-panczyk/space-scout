extends CheckButton
class_name SettingCheckButton

enum SETTING{
	GESTURE,
	NAVIGATION
}
@export var setting:SETTING

func _ready() -> void:
	if setting == SETTING.GESTURE:
		button_pressed = GlobalSettings.gesture_navigation
	else:
		button_pressed = GlobalSettings.virtual_navigation
	#connect("toggled", _toggled)
	
func  _toggled(toggled_on: bool) -> void:
	if setting == SETTING.GESTURE:
		GlobalSettings.set_gesture_navigation(toggled_on)
	else:
		GlobalSettings.set_virtual_navigation(toggled_on)
