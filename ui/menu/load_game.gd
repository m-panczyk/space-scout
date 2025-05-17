extends Control

var title = tr("MENU_IO_LOAD_GAME")

@export var save_menu:bool = false
@onready var saves = SaveData.get_all_save_files()
var game_scene = "res://game.tscn"


func new_game() -> void:
	get_tree().change_scene_to_packed(load(game_scene))

func _ready() -> void:
	if save_menu:
		$Button.text = tr("MENU_IO_SAVE_GAME")
		title = tr("MENU_IO_SAVE_GAME")
	else:
		$Button.text = tr("MENU_IO_LOAD_GAME")
	for save in saves:
		$SavesContainer.add_item(save["save_name"])

func format_datetime(datetime_str: String) -> String:
	# Expected input format: "YYYY-MM-DD_hh-mm-ss" or timestamp format
	# Output format: "YYYY-MM-DD hh:mm"
	
	if datetime_str == "Unknown":
		return "Unknown"
	
	# Split the datetime string
	var parts = datetime_str.split("_")
	if parts.size() < 2:
		return datetime_str # Return original if format unexpected
	
	var date_part = parts[0] # YYYY-MM-DD
	var time_part = parts[1] # hh-mm-ss
	
	# Format time part (convert hh-mm-ss to hh:mm)
	var time_elements = time_part.split("-")
	if time_elements.size() < 2:
		return datetime_str # Return original if format unexpected
	
	var hours = time_elements[0]
	var minutes = time_elements[1]
	
	# Combine into YYYY-MM-DD hh:mm format
	return date_part + " " + hours + ":" + minutes

func _on_saves_container_item_selected(index: int) -> void:
	$Button.disabled = false
	if save_menu:
		$SaveDetails/DelSave.disabled = false
	var save = saves[index]
	
	# Format the date and time in the requested format
	var datetime = save.get("save_date", "Unknown")
	var formatted_datetime = format_datetime(datetime)
	
	# Format creation date similarly
	var creation_date = save.get("creation_date", "Unknown")
	var formatted_creation = format_datetime(creation_date)
	
	var details = """
[b]{save_name}[/b]
Poziom trudności: [color=#ffcc00]{difficulty}[/color]
Punkty: [color=#00ccff]{points}[/color]
Utworzono: {creation}
Ostatni Zapis: {datetime}
""".format({
		"save_name": save.get("save_name", "Unknown"),
		"difficulty": save.get("difficulty_name", "Normal"),
		"points": str(save.get("points", 0)),
		"creation": formatted_creation,
		"datetime": formatted_datetime,
	})
	
	# Check if SaveDetails is a RichTextLabel to use BBCode, otherwise use plain text
	if $SaveDetails is RichTextLabel:
		$SaveDetails.text = details
	else:
		# For regular Label, remove BBCode tags
		var plain_text = details.replace("[b]", "").replace("[/b]", "")
		plain_text = plain_text.replace("[color=#ffcc00]", "").replace("[/color]", "")
		plain_text = plain_text.replace("[color=#00ccff]", "").replace("[/color]", "")
		$SaveDetails.text = plain_text


func _on_button_pressed() -> void:
	if save_menu:
		SaveData.save_game(saves[$SavesContainer.get_selected_items()[0]]["save_name"])
		refresh()
	else:
		if SaveData.load_game(saves[$SavesContainer.get_selected_items()[0]]["path"]):
			new_game()

func _on_new_save_pressed() -> void:
	$NewSavePopup.show()
	$SaveDetails/NewSave.disabled = true
	$Button.disabled = true
	$SaveDetails/DelSave.disabled = true

func refresh():
	# Refresh the saves list to show the new save
	saves = SaveData.get_all_save_files()
	$SavesContainer.clear()
	for save in saves:
		$SavesContainer.add_item(save["save_name"])
	$SavesContainer.select(0,true)
	_on_saves_container_item_selected(0)


func _on_new_save_button_pressed() -> void:
	SaveData.save_game(%NewSaveName.text)
	$NewSavePopup.hide()
	refresh()


func _on_del_save_pressed() -> void:
	# Check if a save is selected
	var selected_items = $SavesContainer.get_selected_items()
	if selected_items.size() == 0:
		# No save selected, show a message
		var popup = AcceptDialog.new()
		popup.title = tr("MENU_IO_ERROR")
		popup.dialog_text = tr("MENU_IO_NO_SAVE_SELECTED")
		add_child(popup)
		popup.popup_centered()
		await popup.confirmed
		popup.queue_free()
		return
	
	# Get the selected save
	var index = selected_items[0]
	var save = saves[index]
	
	# Create confirmation dialog
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = tr("MENU_IO_CONFIRM_DELETE")
	confirm_dialog.dialog_text = tr("MENU_IO_DELETE_CONFIRMATION").format({"save_name": save["save_name"]})
	confirm_dialog.get_ok_button().text = tr("MENU_IO_DELETE")
	confirm_dialog.get_cancel_button().text = tr("MENU_IO_CANCEL")
	add_child(confirm_dialog)
	
	# Show the dialog
	confirm_dialog.popup_centered()
	
	# Connect the signals
	confirm_dialog.confirmed.connect(func():
		# Delete the save file
		var file_path = save["path"]
		if FileAccess.file_exists(file_path):
			var error = DirAccess.remove_absolute(file_path)
			if error != OK:
				push_error("Failed to delete save file: " + file_path + ", error: " + str(error))
				var error_popup = AcceptDialog.new()
				error_popup.title = tr("MENU_IO_ERROR")
				error_popup.dialog_text = tr("MENU_IO_DELETE_ERROR")
				add_child(error_popup)
				error_popup.popup_centered()
				await error_popup.confirmed
				error_popup.queue_free()
			else:
				# Success - refresh the save list
				refresh()
				# Clear the save details if there are no more saves
				if saves.size() == 0:
					$SaveDetails.text = ""
					$Button.disabled = true
					$SaveDetails/DelSave.disabled = true
				elif index < saves.size():
					# Select the save at the same index if available
					$SavesContainer.select(index)
					_on_saves_container_item_selected(index)
				else:
					# Otherwise select the last save
					var new_index = saves.size() - 1
					$SavesContainer.select(new_index)
					_on_saves_container_item_selected(new_index)
		
		confirm_dialog.queue_free()
	)
	
	# Connect the canceled signal
	confirm_dialog.canceled.connect(func():
		confirm_dialog.queue_free()
	)


func _on_new_save_popup_popup_hide() -> void:
	$SaveDetails/NewSave.disabled = false
