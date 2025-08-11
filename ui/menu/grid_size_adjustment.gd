extends GridContainer

func _ready() -> void:
	if size.x > $"../../../..".size.x:
		columns = 1
