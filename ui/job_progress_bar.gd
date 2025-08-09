extends ProgressBar
class_name JobProgressBar

var job_name: String
var job_label: Label
var job_effect_function: Callable

func _ready() -> void:
	# Set up the progress bar
	max_value = GameState.job_cost
	
	connect("value_changed", _on_value_changed)
	
	# Create and configure label
	job_label = Label.new()
	job_label.text = job_name
	job_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(job_label)
	
	custom_minimum_size = Vector2(0, 64)
	
	# Style the progress bar
	add_theme_color_override("font_color", Color.WHITE)

func _on_value_changed(value: float) -> void:
	# Update label to show progress
	var progress_text = "%s (%d/%d)" % [job_name, int(value), int(max_value)]
	job_label.text = progress_text
	
	# Check if job is complete
	if value >= max_value:
		complete_job()

func complete_job() -> void:
	# Execute the job's effect function
	if job_effect_function and job_effect_function.is_valid():
		job_effect_function.call()
		print("Job completed: ", job_name)
		EventBus.emit("stats_update",null)
	else:
		push_warning("JobProgressBar: No valid effect function for job: " + job_name)
	
	# Notify that job is finished (for UI updates, etc.)
	EventBus.emit("job_completed_ui", job_name)
	
	# Remove this progress bar
	queue_free()

func set_job_effect(effect: Callable) -> void:
	job_effect_function = effect
