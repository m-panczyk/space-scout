extends HSlider

var zoom_node

func _ready() -> void:
	zoom_node = %HexTileController
	value = zoom_node.get_zoom()



func _on_value_changed(new_value: float) -> void:
	zoom_node.set_zoom(new_value)
