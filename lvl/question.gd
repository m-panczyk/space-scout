extends RichTextLabel

func show_question():
	text = GlobalSettings.get_question()
	move_to_center_panel()
	get_parent().show()

func hide_question():
	get_parent().hide()

func move_to_center_panel():
	var center_panel_3d = %CenterPanel
	if center_panel_3d:
		var camera = get_viewport().get_camera_3d()
		if camera:
			# Get the world size from the ThreeWayPanel
			var world_size = center_panel_3d.get_world_size()
			
			# Convert world size to screen size
			var top_left_world = center_panel_3d.global_position + Vector3(-world_size.x / 2, world_size.y / 2, 0)
			var bottom_right_world = center_panel_3d.global_position + Vector3(world_size.x / 2, -world_size.y / 2, 0)
			
			var top_left_screen = camera.unproject_position(top_left_world)
			var bottom_right_screen = camera.unproject_position(bottom_right_world)
			
			var panel_screen_width = abs(bottom_right_screen.x - top_left_screen.x)
			var panel_screen_height = abs(bottom_right_screen.y - top_left_screen.y)
			
			# Set parent size: 100% width, 20% height of center panel
			var new_size = Vector2(panel_screen_width, panel_screen_height * 0.2)
			get_parent().size = new_size
			
			# Calculate the top center position
			var top_center_global = center_panel_3d.global_position + Vector3(0, world_size.y / 2, 0)
			var screen_pos = camera.unproject_position(top_center_global)
			
			# Center the UI horizontally and position it above the 3D object
			get_parent().position = Vector2(screen_pos.x - new_size.x / 2, 
											screen_pos.y)
