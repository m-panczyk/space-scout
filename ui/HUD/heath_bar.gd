extends ProgressBar

@export var data_type = 'health'

var label:Label
func _enter_tree() -> void:
	EventBus.subscribe(data_type+"_changed",_on_data_changed)
	label = Label.new()

func  _ready() -> void:
	add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
func _on_data_changed(data:Array):
	value = data[0]
	max_value = data[1]
	label.text = tr("GAME_CHARACTER_"+data_type.to_upper())+" "+str(int(value))+"/"+str(int(max_value))

func _exit_tree() -> void:
	EventBus.unsubscribe(data_type+"_changed",_on_data_changed)
