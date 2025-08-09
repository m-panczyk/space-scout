extends Button
class_name JobButton
@export var job_name: String

func _ready() -> void:
	if job_name.is_empty(): 
		job_name = get_parent().name

	pressed.connect(add_job_to_queue)

func add_job_to_queue() -> void:
	EventBus.emit("add_job", job_name)
