extends SubViewportContainer

func set_zoom(new_zoom:float):
	%Camera2D.zoom = Vector2(new_zoom,new_zoom)
	#$SubViewport/ParallaxBg/ParallaxLayer/Sprite2D.scale = Vector2(1.0/new_zoom,1.0/new_zoom)
func get_zoom() -> float:
	return %Camera2D.zoom.x
