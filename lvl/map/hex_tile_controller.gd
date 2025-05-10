extends SubViewportContainer

func set_zoom(new_zoom:float):
	%Camera2D.zoom = Vector2(new_zoom,new_zoom)
func get_zoom() -> float:
	return %Camera2D.zoom.x
