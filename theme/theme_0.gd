@tool
extends ProgrammaticTheme

func setup():
	set_save_path("res://theme/default.tres")
func define_theme():
	define_default_font_size(24)
	define_default_font(ResourceLoader.load("res://theme/Roboto-VariableFont_wdth,wght.ttf"))
