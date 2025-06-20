extends Actor
class_name Player

# Private backing fields
var _weapon_name = SaveData.weapon_name
var _energy:int = SaveData.energy
var _energy_max = SaveData.energy_max
var _energy_production = SaveData.energy_production

# Public properties with getters/setters
var weapon_name:
	get:
		return _weapon_name
	set(value):
		_weapon_name = value
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

var energy_production_timer: Timer
var weapon:Weapon

func _init() -> void:
	if skin_path == "":
		skin_path = "res://actors/player/img/base_0.tscn"

func get_animation() -> AnimatedSprite2D:
	return $Skin.get_child(0)
	
func get_size() -> Vector2:
	return get_animation().sprite_frames.get_frame_texture(get_animation().animation,0).get_size()

func _alt_ready() -> void:
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

func _exit_tree() -> void:
	EventBus.unsubscribe("player_fire",fire_weapon)

func _on_energy_production_timer_timeout():
	if energy < energy_max:
		energy += energy_production[0]
		# No need to update SaveData.energy here as the setter handles it

func process_clamping():
	var screen_size = GlobalSettings.virtual_resolution
	position = position.clamp(Vector2.ZERO, screen_size)

func health_changed():
	SaveData.health = health
	EventBus.emit("health_changed", [health,max_health])

func process_move(delta: float):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		get_animation().frame = 1
		velocity.x -=1
	if Input.is_action_pressed("ui_right"):
		get_animation().frame = 2
		velocity.x +=1
	if velocity.x == 0:
		get_animation().frame = 0
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	position += velocity * delta

func _input(event: InputEvent) -> void:
	if event.is_action("game_fire"):
		fire_weapon()

func fire_weapon():
	if energy >= weapon.consumption:
		weapon.fire()
		energy -= weapon.consumption
		# No need to update SaveData.energy here as the setter handles it

func died():
	health = max_health
	#EventBus.emit("game_over",false)
