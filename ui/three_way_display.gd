class_name ThreeWayDisplay
extends Node3D

## Three-panel display system with smart camera control and touch-to-focus
## Left: Player stats, inventory, upgrades
## Center: Main gameplay viewport  
## Right: Map and game progression stats

signal panel_changed(panel_type: PanelType)
signal transition_complete

enum PanelType {
	LEFT_PANEL,    # Player stats, inventory, upgrades
	CENTER_PANEL,  # Main gameplay
	RIGHT_PANEL    # Map and game stats
}

@export_group("Display Configuration")
@export var panel_size: Vector2i = Vector2i(1080, 1920)
@export var transition_duration: float = 1.0
@export var auto_adjust_on_resize: bool = true

@export_group("Input Settings")
@export var enable_input: bool = true
@export var block_input_during_transition: bool = true
@export var enable_touch_to_focus: bool = true  # Touch to focus on partially visible panels
@export var enable_right_click_to_focus: bool = true  # Right-click to focus on partially visible panels

# Components
@onready var camera: ThreeWayCamera3D = $ThreeWayCamera3D
@onready var panels_container: Node3D = $Panels

# Panel references
var left_panel: ThreeWayPanel
var center_panel: ThreeWayPanel
var right_panel: ThreeWayPanel

var current_panel_type: PanelType = PanelType.CENTER_PANEL

func _ready():
	find_required_nodes()
	setup_camera()
	connect_signals()
	
	# Start with center panel (gameplay)
	switch_to_panel(PanelType.CENTER_PANEL, false)

func find_required_nodes():
	"""Find required nodes in scene - throw errors if missing"""
	camera = $ThreeWayCamera3D
	if not camera:
		push_error("ThreeWayDisplay: Missing ThreeWayCamera3D node")
		return
	
	panels_container = $Panels
	if not panels_container:
		push_error("ThreeWayDisplay: Missing Panels node")
		return
	
	left_panel = $Panels/LeftPanel
	if not left_panel:
		push_error("ThreeWayDisplay: Missing Panels/LeftPanel node")
		return
		
	center_panel = $Panels/CenterPanel
	if not center_panel:
		push_error("ThreeWayDisplay: Missing Panels/CenterPanel node")
		return
		
	right_panel = $Panels/RightPanel
	if not right_panel:
		push_error("ThreeWayDisplay: Missing Panels/RightPanel node")
		return

func setup_camera():
	if not camera:
		push_error("ThreeWayDisplay: Camera not found during setup")
		return
	
	# Configure camera with our panels
	var sprites = [left_panel.get_sprite3d(), center_panel.get_sprite3d(), right_panel.get_sprite3d()]
	camera.initialize_with_panels(sprites)
	camera.transition_duration = transition_duration
	camera.auto_adjust_on_resize = auto_adjust_on_resize

func connect_signals():
	camera.panel_changed.connect(_on_camera_panel_changed)
	camera.transition_complete.connect(_on_camera_transition_complete)
	
	# Connect panel touch signals for focus functionality
	if enable_touch_to_focus or enable_right_click_to_focus:
		left_panel.panel_touched.connect(_on_panel_touched)
		center_panel.panel_touched.connect(_on_panel_touched)
		right_panel.panel_touched.connect(_on_panel_touched)
	
	if auto_adjust_on_resize:
		get_viewport().size_changed.connect(_on_viewport_resized)

func _on_panel_touched(panel: ThreeWayPanel):
	"""Handle panel touch/right-click events for focus functionality"""
	if not enable_touch_to_focus and not enable_right_click_to_focus:
		return
	
	# Don't switch if already transitioning
	if camera.is_camera_transitioning():
		return
	
	# Determine which panel was touched and switch to it
	var target_panel_type: PanelType
	if panel == left_panel:
		target_panel_type = PanelType.LEFT_PANEL
	elif panel == center_panel:
		target_panel_type = PanelType.CENTER_PANEL
	elif panel == right_panel:
		target_panel_type = PanelType.RIGHT_PANEL
	else:
		return  # Unknown panel
	
	# Switch to the touched panel
	switch_to_panel(target_panel_type, true)

func _input(event):
	# Input handling moved to game.gd - this base class no longer processes input
	pass

func switch_to_panel(panel_type: PanelType, animate: bool = true):
	"""Switch to specific panel by type"""
	if panel_type == current_panel_type:
		return
	
	current_panel_type = panel_type
	camera.switch_to_panel_index(int(panel_type), animate)

func switch_to_panel_to_the_right():
	"""Switch to panel to the right (left->center->right, stop at right)"""
	match current_panel_type:
		PanelType.LEFT_PANEL:
			switch_to_panel(PanelType.CENTER_PANEL)
		PanelType.CENTER_PANEL:
			switch_to_panel(PanelType.RIGHT_PANEL)
		PanelType.RIGHT_PANEL:
			pass  # Already at rightmost panel, do nothing

func switch_to_panel_to_the_left():
	"""Switch to panel to the left (right->center->left, stop at left)"""
	match current_panel_type:
		PanelType.RIGHT_PANEL:
			switch_to_panel(PanelType.CENTER_PANEL)
		PanelType.CENTER_PANEL:
			switch_to_panel(PanelType.LEFT_PANEL)
		PanelType.LEFT_PANEL:
			pass  # Already at leftmost panel, do nothing

func get_current_panel() -> ThreeWayPanel:
	"""Get currently active panel"""
	match current_panel_type:
		PanelType.LEFT_PANEL: return left_panel
		PanelType.CENTER_PANEL: return center_panel
		PanelType.RIGHT_PANEL: return right_panel
		_: return center_panel

func set_panel_content(panel_type: PanelType, content_scene: PackedScene):
	"""Dynamically change panel content"""
	var panel = get_panel_by_type(panel_type)
	if panel:
		panel.set_content_scene(content_scene)

func get_panel_viewport(panel_type: PanelType) -> SubViewport:
	"""Get viewport for direct content manipulation"""
	var panel = get_panel_by_type(panel_type)
	return panel.get_panel_viewport() if panel else null

func enable_panel(panel_type: PanelType, enabled: bool):
	"""Enable/disable specific panel"""
	var panel = get_panel_by_type(panel_type)
	if panel:
		panel.set_panel_enabled(enabled)

func set_focus_controls_enabled(touch_enabled: bool, right_click_enabled: bool):
	"""Enable or disable touch-to-focus and right-click-to-focus functionality"""
	enable_touch_to_focus = touch_enabled
	enable_right_click_to_focus = right_click_enabled
	
	if touch_enabled or right_click_enabled:
		# Connect signals if not already connected
		if not left_panel.panel_touched.is_connected(_on_panel_touched):
			left_panel.panel_touched.connect(_on_panel_touched)
		if not center_panel.panel_touched.is_connected(_on_panel_touched):
			center_panel.panel_touched.connect(_on_panel_touched)
		if not right_panel.panel_touched.is_connected(_on_panel_touched):
			right_panel.panel_touched.connect(_on_panel_touched)
	else:
		# Disconnect signals
		if left_panel.panel_touched.is_connected(_on_panel_touched):
			left_panel.panel_touched.disconnect(_on_panel_touched)
		if center_panel.panel_touched.is_connected(_on_panel_touched):
			center_panel.panel_touched.disconnect(_on_panel_touched)
		if right_panel.panel_touched.is_connected(_on_panel_touched):
			right_panel.panel_touched.disconnect(_on_panel_touched)

## Internal Methods

func get_panel_by_type(panel_type: PanelType) -> ThreeWayPanel:
	match panel_type:
		PanelType.LEFT_PANEL: return left_panel
		PanelType.CENTER_PANEL: return center_panel
		PanelType.RIGHT_PANEL: return right_panel
		_: return null

func _on_camera_panel_changed(panel_index: int):
	current_panel_type = panel_index as PanelType
	panel_changed.emit(current_panel_type)

func _on_camera_transition_complete():
	transition_complete.emit()

func _on_viewport_resized():
	if camera:
		camera.handle_viewport_resize()

## Utility Methods for Game Integration

func show_gameplay():
	"""Convenience method to show main gameplay"""
	switch_to_panel(PanelType.CENTER_PANEL)

func show_inventory():
	"""Convenience method to show inventory/player stats"""
	switch_to_panel(PanelType.LEFT_PANEL)

func show_map():
	"""Convenience method to show map/game stats"""
	switch_to_panel(PanelType.RIGHT_PANEL)

func is_showing_gameplay() -> bool:
	"""Check if currently showing gameplay panel"""
	return current_panel_type == PanelType.CENTER_PANEL

func pause_transitions():
	"""Disable camera transitions (useful during loading)"""
	camera.transition_duration = 0.0

func resume_transitions():
	"""Re-enable camera transitions"""
	camera.transition_duration = transition_duration

func can_switch_to_right() -> bool:
	"""Check if can switch to panel to the right"""
	return current_panel_type != PanelType.RIGHT_PANEL

func can_switch_to_left() -> bool:
	"""Check if can switch to panel to the left"""
	return current_panel_type != PanelType.LEFT_PANEL
