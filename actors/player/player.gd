extends Actor
class_name Player

@export var weapon_name = 'basic'
@export var energy:int = 1
@export var energy_max = 10
@export var energy_production = [1,1]
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
	health_changed()
	if speed == Actor.DEFAULT_SPEED:
		speed = 400
		
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
	if energy<energy_max:
		energy += energy_production[0]
		energy = min(energy, energy_max)
		EventBus.emit("energy_changed", [energy,energy_max])


func process_clamping():
	var screen_size = GlobalSettings.virtual_resolution
	position = position.clamp(Vector2.ZERO, screen_size)

func health_changed():
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
		EventBus.emit("energy_changed", [energy,energy_max])
func died():
	EventBus.emit("game_over",[false,0])
