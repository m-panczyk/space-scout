extends MarginContainer
class_name NinePatchMargin

@onready var parent: NinePatchRect

func _ready() -> void:
	parent = get_parent()
	set_margins()

func set_margins():
	add_theme_constant_override("margin_top", parent.patch_margin_top/2)
	add_theme_constant_override("margin_bottom", parent.patch_margin_bottom/2)
	add_theme_constant_override("margin_left", parent.patch_margin_left/2)
	add_theme_constant_override("margin_right", parent.patch_margin_right/2)
