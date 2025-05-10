extends HSlider

@export var zoom_capable_node_name = "../HexTileController"
var zoom_node

func _ready() -> void:
	zoom_node = get_node(zoom_capable_node_name)
	value = zoom_node.get_zoom()



func _on_value_changed(value: float) -> void:
	zoom_node.set_zoom(value)
