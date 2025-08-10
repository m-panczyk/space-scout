extends Actor
class_name Player

# Private backing fields
var _weapon_name = SaveData.weapon_name
var _energy:int = SaveData.energy
var _energy_max = SaveData.energy_max
var _energy_production = SaveData.energy_production

# Public properties with getters/setters
var animation:AnimatedSprite2D
var target_position: Vector2
var move_to_target: bool = false

var weapon_name:
	get:
		return _weapon_name
	set(value):
		_weapon_name = value
		var load_weapon = load("res://actors/weapons/"+weapon_name+".tscn")
		weapon = load_weapon.instantiate()
		if value == SaveData.weapon_name:
			weapon.consumption = SaveData.weapon_cost
		SaveData.weapon_name = value

var energy:int:
	get:
		return _energy
	set(value):
		_energy = value
		SaveData.energy = value
		EventBus.emit("energy_changed", [_energy, energy_max])

var energy_max:
	get:
		return _energy_max
	set(value):
		_energy_max = value
		SaveData.energy_max = value
		EventBus.emit("energy_changed", [energy, _energy_max])

var energy_production:
	get:
		return _energy_production
	set(value):
		_energy_production = value
		SaveData.energy_production = value
var weapon:Weapon
var weapon_cost:
	get:
		return weapon.consumption
	set(value):
		weapon.consumption = value
		SaveData.weapon_cost = value

var energy_production_timer: Timer

func _init() -> void:
	if skin_path == "":
		skin_path = "res://actors/player/img/base_0.tscn"

func get_animation() -> AnimatedSprite2D:
	return $Skin.get_child(0)
	
func get_size() -> Vector2:
	return get_animation().sprite_frames.get_frame_texture(get_animation().animation,0).get_size()

func _ready() -> void:
	super()
	animation = get_animation()
	for rouge_player in get_tree().get_nodes_in_group("PLAYER"):
		rouge_player.queue_free()
	add_to_group("PLAYER")
	health = SaveData.health
	max_health = SaveData.health_max
	health_changed()
	if speed == Actor.DEFAULT_SPEED:
		speed = 400
	var _scale = (GlobalSettings.virtual_resolution.x/5)/get_size().x
	scale = Vector2(_scale,_scale)
	collision_layer = 1
	collision_mask = 2
	
	#energy production
	energy_production_timer = Timer.new()
	energy_production_timer.wait_time = energy_production[1]
	energy_production_timer.one_shot = false
	energy_production_timer.autostart = true
	add_child(energy_production_timer)
	_on_energy_production_timer_timeout()
	energy_production_timer.timeout.connect(_on_energy_production_timer_timeout)
	
	if weapon_name != '':
		var load_weapon = load("res://actors/weapons/"+weapon_name+".tscn")
		weapon = load_weapon.instantiate()
		add_child(weapon)
		EventBus.subscribe("player_fire",fire_weapon)
	EventBus.subscribe("gameplay_clicked", _on_gameplay_clicked)
	EventBus.subscribe("gameplay_click_released", _on_gameplay_click_released)
	EventBus.subscribe("gameplay_double_clicked", _on_gameplay_double_clicked)
	var upgrade_manager = UpgradeManager.new()
	upgrade_manager.player = self
	add_child(upgrade_manager)

func _exit_tree() -> void:
	EventBus.unsubscribe("player_fire",fire_weapon)
	EventBus.unsubscribe("gameplay_clicked", _on_gameplay_clicked)
	EventBus.unsubscribe("gameplay_click_released", _on_gameplay_click_released)
	EventBus.unsubscribe("gameplay_double_clicked", _on_gameplay_double_clicked)
	
func _on_energy_production_timer_timeout():
	if energy < energy_max:
		energy += energy_production[0]
	elif GameState.game_on:
		EventBus.emit("sulprus_energy",energy_production[0])

func process_clamping():
	var screen_size = GlobalSettings.virtual_resolution
	position = position.clamp(Vector2.ZERO, screen_size)

func health_changed():
	SaveData.health = health
	EventBus.emit("health_changed", [health,max_health])
	SaveData.health = health
	SaveData.health_max = max_health
func _on_gameplay_clicked(click_position: Vector2):
	target_position = click_position
	move_to_target = true

func _on_gameplay_click_released(_click_posiotion: Vector2):
	move_to_target = false
	animation.frame = 0  # Reset to idle animation

func _on_gameplay_double_clicked(click_position: Vector2):
	# Double-click fires weapon instead of moving
	fire_weapon()
	
func process_move(delta: float):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("game_fire"):
		fire_weapon()
	
	# Handle move-to-target from click
	if move_to_target:
		var direction_to_target = (target_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target_position)
		
		# Stop moving when close enough
		if distance_to_target < 10.0:  # Adjust threshold as needed
			move_to_target = false
			animation.frame = 0
		else:
			velocity = direction_to_target
			# Set animation based on direction
			if abs(direction_to_target.x) > abs(direction_to_target.y):
				animation.frame = 2 if direction_to_target.x > 0 else 1
			else:
				animation.frame = 0
	else:
		# Standard keyboard input (only when not moving to target)
		if Input.is_action_pressed("ui_left"):
			animation.frame = 1
			velocity.x -= 1
		if Input.is_action_pressed("ui_right"):
			animation.frame = 2
			velocity.x += 1
		if velocity.x == 0:
			animation.frame = 0
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		
		# Allow keyboard input to override click movement
		if velocity.length() > 0:
			move_to_target = false
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	position += velocity * delta

func fire_weapon():
	if energy >= weapon.consumption:
		weapon.fire()
		energy -= weapon.consumption

func died():
	queue_free()
	GameState.died = true
	get_tree().change_scene_to_file("res://lvl/endgame.tscn")

func _on_screen_exited() -> void:
	pass
