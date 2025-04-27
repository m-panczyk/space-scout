extends Area2D
class_name Actor

const DEFAULT_SPEED = 100
@export var damage = 99999
@export var health = 1
@export var max_health = 1
@export var speed = DEFAULT_SPEED
@export var direction = Vector2.ZERO
@export var skin_path = ""

var visibility_notifier: VisibleOnScreenNotifier2D

func _enter_tree() -> void:
	if skin_path != "":
		var skin_instance = load(skin_path).instantiate()
		add_child(skin_instance)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	# Add VisibilityNotifier2D
	visibility_notifier = VisibleOnScreenNotifier2D.new()
	add_child(visibility_notifier)
	
	# Connect visibility signals
	visibility_notifier.screen_entered.connect(_on_screen_entered)
	visibility_notifier.screen_exited.connect(_on_screen_exited)
	
	_alt_ready()

func _alt_ready() -> void:
	pass

func _process(delta: float) -> void:
	process_move(delta)
	process_clamping()
	
func process_move(delta: float) -> void:
	var velocity = direction.normalized() * speed
	position += velocity * delta
	

func process_clamping() -> void:
	pass

func _on_area_entered(other_area) -> void:
	if other_area.has_method("get_damage"):
		health = health - other_area.get_damage()
		health_changed()
	if health <= 0 :
		died()
	if health > max_health:
		health = max_health

func get_damage():
	return damage

func health_changed():
	pass

func died():
	queue_free()
	
func _on_screen_entered() -> void:
	pass

func _on_screen_exited() -> void:
	died()

func get_size() -> Vector2:
	return get_child(0).get_child(0).texture.get_size()
