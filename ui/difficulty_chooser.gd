extends Control

var title = "Nowa Gra"

# Nowe zmienne dla systemu przedmiotów
var selected_subject: QGen.Przedmiot = QGen.Przedmiot.MATEMATYKA

# Referencje do istniejących elementów UI
@onready var easy_button: Button
@onready var normal_button: Button  
@onready var hard_button: Button
@onready var easy_description: RichTextLabel
@onready var normal_description: RichTextLabel
@onready var hard_description: RichTextLabel
@onready var item_list_container: BoxContainer

# Nowe elementy dla wyboru przedmiotu
var subject_container: VBoxContainer
var subject_label: Label
var subject_option_button: OptionButton
var stats_label: RichTextLabel

func _ready() -> void:
	get_ui_references()
	add_subject_selection()
	setup_subject_descriptions()
	update_difficulty_descriptions()
	update_layout()
	
	# Połącz signal zmiany rozmiaru ekranu
	get_viewport().connect("size_changed", _on_viewport_size_changed)

func update_layout():
	# Sprawdź orientację ekranu
	var is_portrait = get_viewport_rect().size.x < get_viewport_rect().size.y
	
	# Ustaw orientację kontenera
	if item_list_container is BoxContainer:
		item_list_container.vertical = is_portrait
	
	# Ustaw size_flags dla przycisków w zależności od orientacji
	if is_portrait:
		# W trybie pionowym - przyciski powinny rozciągać się w pionie
		easy_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		normal_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hard_button.size_flags_vertical = Control.SIZE_EXPAND_FILL

	else:
		# W trybie poziomym - przyciski powinny rozciągać się w poziomie
		easy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		normal_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	
	# Dostosuj rozmiar sekcji wyboru przedmiotu
	if subject_container:
		if is_portrait:
			subject_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			subject_option_button.custom_minimum_size = Vector2(250, 50)
			# Dodaj większe marginesy w trybie pionowym
			if subject_container.get("theme_override_constants/separation") != null:
				subject_container.add_theme_constant_override("separation", 10)
		else:
			subject_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER  
			subject_option_button.custom_minimum_size = Vector2(300, 40)
			# Mniejsze marginesy w trybie poziomym
			if subject_container.get("theme_override_constants/separation") != null:
				subject_container.add_theme_constant_override("separation", 5)
	
	print("Layout zaktualizowany - orientacja: ", "pionowa" if is_portrait else "pozioma")

func _on_viewport_size_changed():
	# Reaguj na zmiany rozmiaru okna/orientacji
	update_layout()

func get_ui_references():
	# Pobierz referencje do istniejących elementów
	item_list_container = $ItemList
	easy_button = $ItemList/Easy
	normal_button = $ItemList/Normal  
	hard_button = $ItemList/Hard
	easy_description = $ItemList/Easy/RichTextLabel
	normal_description = $ItemList/Normal/RichTextLabel2
	hard_description = $ItemList/Hard/RichTextLabel3

func add_subject_selection():
	# Dodaj sekcję wyboru przedmiotu na górze
	subject_container = VBoxContainer.new()
	subject_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Przenieś subject_container na początek
	item_list_container.add_child(subject_container)
	item_list_container.move_child(subject_container, 0)
	
	# Tytuł sekcji przedmiotów
	subject_label = Label.new()
	subject_label.text = "🎓 Wybierz przedmiot:"
	subject_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subject_label.add_theme_font_size_override("font_size", 24)
	subject_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject_container.add_child(subject_label)
	
	# Lista wyboru przedmiotu
	subject_option_button = OptionButton.new()
	subject_option_button.custom_minimum_size = Vector2(300, 50)
	subject_option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject_option_button.add_theme_font_size_override("font_size", 20)
	populate_subjects()
	subject_option_button.connect("item_selected", _on_subject_selected)
	subject_container.add_child(subject_option_button)
	
	# Separator
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 20)
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject_container.add_child(separator)
	
	# Statystyki
	stats_label = RichTextLabel.new()
	stats_label.custom_minimum_size = Vector2(0, 80)
	stats_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stats_label.bbcode_enabled = true
	stats_label.fit_content = true
	stats_label.scroll_active = false
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subject_container.add_child(stats_label)
	
	update_stats()

func populate_subjects():
	var subjects = QGen.get_available_subjects()
	
	for i in range(subjects.size()):
		var subject = subjects[i]
		var subject_name = QGen.get_subject_name(subject)
		var icon = get_subject_icon(subject)
		
		var display_text = icon + " " + subject_name
		subject_option_button.add_item(display_text)
		subject_option_button.set_item_metadata(i, subject)
	
	# Wybierz matematykę domyślnie
	subject_option_button.select(0)
	selected_subject = QGen.Przedmiot.MATEMATYKA

func get_subject_icon(subject: QGen.Przedmiot) -> String:
	match subject:
		QGen.Przedmiot.MATEMATYKA: return "🔢"
		QGen.Przedmiot.GEOGRAFIA: return "🌍"
		QGen.Przedmiot.HISTORIA: return "🏛️"
		QGen.Przedmiot.PRZYRODA: return "🌿"
		QGen.Przedmiot.POLSKI: return "📚"
		QGen.Przedmiot.ANGIELSKI: return "🇬🇧"
		_: return "📖"

func setup_subject_descriptions():
	# Przygotuj mapę opisów dla różnych przedmiotów
	pass

func update_difficulty_descriptions():
	# Aktualizuj opisy przycisków w zależności od wybranego przedmiotu
	var descriptions = get_descriptions_for_subject(selected_subject)
	
	easy_description.text = descriptions["easy"]
	normal_description.text = descriptions["normal"] 
	hard_description.text = descriptions["hard"]

func get_descriptions_for_subject(subject: QGen.Przedmiot) -> Dictionary:
	match subject:
		QGen.Przedmiot.MATEMATYKA:
			return {
				"easy": "[b]10-11 lat[/b]\n- Dodawanie i odejmowanie w zakresie 50\n- Tabliczka mnożenia",
				"normal": "[b]12-13 lat[/b]\n- Podzielność\n- Procenty", 
				"hard": "[b]14-15 lat[/b]\n- Zaokrąglanie\n- Potęgi"
			}
		QGen.Przedmiot.GEOGRAFIA:
			return {
				"easy": "[b]10-11 lat[/b]\n- Mapa świata\n- Ukształtowanie terenu",
				"normal": "[b]12-13 lat[/b]\n- Klimat\n- Geografia Polski",
				"hard": "[b]14-15 lat[/b]\n- Geologia\n- Geografia gospodarki"
			}
		QGen.Przedmiot.HISTORIA:
			return {
				"easy": "[b]10-11 lat[/b]\n- Historia starożytna\n- Historia średniowiecza",
				"normal": "[b]12-13 lat[/b]\n- Historia Polski\n- Historia nowożytna",
				"hard": "[b]14-15 lat[/b]\n- Historia współczesna\n- Historia powszechna"
			}
		QGen.Przedmiot.PRZYRODA:
			return {
				"easy": "[b]10-11 lat[/b]\n- Zwierzęta\n- Rośliny",
				"normal": "[b]12-13 lat[/b]\n- Ciało człowieka\n- Podstawy fizyki",
				"hard": "[b]14-15 lat[/b]\n- Podstawy chemii\n- Ekologia"
			}
		QGen.Przedmiot.POLSKI:
			return {
				"easy": "[b]10-11 lat[/b]\n- Ortografia\n- Części mowy",
				"normal": "[b]12-13 lat[/b]\n- Gramatyka\n- Literatura",
				"hard": "[b]14-15 lat[/b]\n- Zaawansowana gramatyka\n- Analiza literacka"
			}
		QGen.Przedmiot.ANGIELSKI:
			return {
				"easy": "[b]10-11 lat[/b]\n- Colors & Numbers\n- Simple sentences",
				"normal": "[b]12-13 lat[/b]\n- Vocabulary\n- Grammar",
				"hard": "[b]14-15 lat[/b]\n- Advanced grammar\n- Complex vocabulary"
			}
		_:
			return {
				"easy": "[b]10-11 lat[/b]\n- Podstawowy poziom",
				"normal": "[b]12-13 lat[/b]\n- Średni poziom",
				"hard": "[b]14-15 lat[/b]\n- Zaawansowany poziom"
			}

func update_stats():
	if not stats_label:
		return
	
	var stats_text = ""
	
	# Pokaż statystyki dla wybranego przedmiotu
	var subject_stats = SaveData.get_subject_stats(selected_subject)
	if subject_stats["progress"].has("questions_answered") and subject_stats["progress"]["questions_answered"] > 0:
		var progress = subject_stats["progress"]
		var accuracy = SaveData.get_subject_accuracy(selected_subject)
		var best_streak = SaveData.get_subject_best_streak(selected_subject)
		
		stats_text += "[center][color=cyan]📊 " + QGen.get_subject_name(selected_subject) + "[/color]\n"
		stats_text += "Pytania: [b]" + str(progress["questions_answered"]) + "[/b] | "
		stats_text += "Poprawność: [b]" + str(int(accuracy)) + "%[/b] | "
		stats_text += "Najlepszy streak: [b]" + str(best_streak) + "[/b][/center]"
	else:
		stats_text += "[center][color=gray]📊 Brak statystyk dla " + QGen.get_subject_name(selected_subject) + "\nRozpocznij grę, aby zobaczyć postępy![/color][/center]"
	
	stats_label.text = stats_text

func _on_subject_selected(index: int):
	selected_subject = subject_option_button.get_item_metadata(index)
	update_difficulty_descriptions()
	update_stats()
	
	print("Wybrano przedmiot: ", QGen.get_subject_name(selected_subject))

# Oryginalne funkcje przycisków - rozszerzone o obsługę przedmiotów
func _on_easy_pressed() -> void:
	SaveData.difficulty_level = 0
	SaveData.current_subject = selected_subject

	
	print("Rozpoczynam grę - Przedmiot: ", QGen.get_subject_name(selected_subject), ", Poziom: 10-11 lat")
	get_tree().change_scene_to_packed(load("res://game.tscn"))

func _on_normal_pressed() -> void:
	SaveData.difficulty_level = 1
	SaveData.current_subject = selected_subject
	
	print("Rozpoczynam grę - Przedmiot: ", QGen.get_subject_name(selected_subject), ", Poziom: 12-13 lat")
	get_tree().change_scene_to_packed(load("res://game.tscn"))

func _on_hard_pressed() -> void:
	SaveData.difficulty_level = 2
	SaveData.current_subject = selected_subject
	
	print("Rozpoczynam grę - Przedmiot: ", QGen.get_subject_name(selected_subject), ", Poziom: 14-15 lat")
	get_tree().change_scene_to_packed(load("res://game.tscn"))

# Funkcje pomocnicze
func get_selected_subject_name() -> String:
	return QGen.get_subject_name(selected_subject)

func get_available_categories_for_current_selection(difficulty: int) -> Array:
	return QGen.get_available_categories(selected_subject, difficulty)

# Funkcja do uzyskania informacji o aktualnym wyborze
func get_selection_info() -> Dictionary:
	return {
		"subject": selected_subject,
		"subject_name": QGen.get_subject_name(selected_subject),
		"icon": get_subject_icon(selected_subject)
	}
