extends VBoxContainer

func _ready() -> void:
	EventBus.subscribe("add_job", add_job)
	EventBus.subscribe("sulprus_energy",receive_energy)

func _exit_tree() -> void:
	EventBus.unsubscribe("add_job", add_job)
	EventBus.unsubscribe("sulprus_energy",receive_energy)

func add_job(job_id: String):
	if get_child_count() < 5:
		var job = JobsDefinitions.get_job(job_id)
		var job_progress = JobProgressBar.new()
		job_progress.job_name = job.name
		job_progress.job_effect_function = job.effect_function
		add_child(job_progress)

func receive_energy(energy):
	if get_child_count() > 1:
		get_child(1).value += energy
