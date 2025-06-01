extends Node

# Stałe dla przedmiotów i kategorii
enum Przedmiot {
	MATEMATYKA,
	GEOGRAFIA,
	HISTORIA,
	PRZYRODA,
	POLSKI,
	ANGIELSKI
}

enum Kategoria {
	# Matematyka
	DODAWANIE_ODEJMOWANIE,
	TABLICZKA_MNOZENIA,
	PODZIELNOSC,
	PROCENT,
	ZAOKRAGLANIE,
	POTEGI,
	
	# Geografia
	MAPA_SWIATA,
	UKSZTALTOWANIE_TERENU,
	KLIMAT,
	GEOGRAFIA_POLSKI,
	GEOLOGIA,
	GEOGRAFIA_GOSPODARKI,
	
	# Historia
	HISTORIA_STAROŻYTNA,
	HISTORIA_ŚREDNIOWIECZA,
	HISTORIA_POLSKI,
	HISTORIA_NOWOŻYTNA,
	HISTORIA_WSPÓŁCZESNA,
	HISTORIA_POWSZECHNA,
	
	# Przyroda
	ZWIERZĘTA,
	ROŚLINY,
	CIAŁO_CZŁOWIEKA,
	FIZYKA_PODSTAWY,
	CHEMIA_PODSTAWY,
	EKOLOGIA,
	
	# Polski
	ORTOGRAFIA,
	GRAMATYKA,
	LITERATURA,
	CZĘŚCI_MOWY,
	
	# Angielski
	VOCABULARY,
	GRAMMAR,
	SIMPLE_SENTENCES,
	COLORS_NUMBERS
}

# Pytania załadowane z plików JSON
var pytania_json = {}

# Istniejący system matematyczny
var lvl_matematyka = [
	[generuj_pytanie_dodawanie_odejmowanie, generuj_pytanie_tabliczka_mnozenia],
	[generuj_pytanie_podzielnosc, generuj_pytanie_procent],
	[generuj_pytanie_zaokraglanie, generuj_pytanie_potegi]
]

# Nowy system rozszerzony
var przedmioty_kategorie = {
	Przedmiot.MATEMATYKA: {
		0: [Kategoria.DODAWANIE_ODEJMOWANIE, Kategoria.TABLICZKA_MNOZENIA],
		1: [Kategoria.PODZIELNOSC, Kategoria.PROCENT],
		2: [Kategoria.ZAOKRAGLANIE, Kategoria.POTEGI]
	},
	Przedmiot.GEOGRAFIA: {
		0: [Kategoria.MAPA_SWIATA, Kategoria.UKSZTALTOWANIE_TERENU],
		1: [Kategoria.KLIMAT, Kategoria.GEOGRAFIA_POLSKI],
		2: [Kategoria.GEOLOGIA, Kategoria.GEOGRAFIA_GOSPODARKI]
	},
	Przedmiot.HISTORIA: {
		0: [Kategoria.HISTORIA_STAROŻYTNA, Kategoria.HISTORIA_ŚREDNIOWIECZA],
		1: [Kategoria.HISTORIA_POLSKI, Kategoria.HISTORIA_NOWOŻYTNA],
		2: [Kategoria.HISTORIA_WSPÓŁCZESNA, Kategoria.HISTORIA_POWSZECHNA]
	},
	Przedmiot.PRZYRODA: {
		0: [Kategoria.ZWIERZĘTA, Kategoria.ROŚLINY],
		1: [Kategoria.CIAŁO_CZŁOWIEKA, Kategoria.FIZYKA_PODSTAWY],
		2: [Kategoria.CHEMIA_PODSTAWY, Kategoria.EKOLOGIA]
	},
	Przedmiot.POLSKI: {
		0: [Kategoria.ORTOGRAFIA, Kategoria.CZĘŚCI_MOWY],
		1: [Kategoria.GRAMATYKA, Kategoria.LITERATURA],
		2: [Kategoria.LITERATURA, Kategoria.GRAMATYKA] # Powtórzenie na wyższym poziomie
	},
	Przedmiot.ANGIELSKI: {
		0: [Kategoria.COLORS_NUMBERS, Kategoria.SIMPLE_SENTENCES],
		1: [Kategoria.VOCABULARY, Kategoria.GRAMMAR],
		2: [Kategoria.GRAMMAR, Kategoria.VOCABULARY] # Zaawansowane gramatyka i słownictwo
	}
}

# Mapowanie kategorii na nazwy plików/ścieżek
var kategoria_do_json_sciezki = {
	# Geografia
	Kategoria.MAPA_SWIATA: ["geografia", "10-11lat", "mapa_swiata"],
	Kategoria.UKSZTALTOWANIE_TERENU: ["geografia", "10-11lat", "uksztaltowanie_terenu"],
	Kategoria.KLIMAT: ["geografia", "12-13lat", "klimat"],
	Kategoria.GEOGRAFIA_POLSKI: ["geografia", "12-13lat", "geografia_polski"],
	Kategoria.GEOLOGIA: ["geografia", "14-15lat", "geologia"],
	Kategoria.GEOGRAFIA_GOSPODARKI: ["geografia", "14-15lat", "geografia_gospodarki"],
	
	# Historia
	Kategoria.HISTORIA_STAROŻYTNA: ["historia", "10-11lat", "historia_starozytna"],
	Kategoria.HISTORIA_ŚREDNIOWIECZA: ["historia", "10-11lat", "historia_sredniowiecza"],
	Kategoria.HISTORIA_POLSKI: ["historia", "12-13lat", "historia_polski"],
	Kategoria.HISTORIA_NOWOŻYTNA: ["historia", "12-13lat", "historia_nowozytna"],
	Kategoria.HISTORIA_WSPÓŁCZESNA: ["historia", "14-15lat", "historia_wspolczesna"],
	Kategoria.HISTORIA_POWSZECHNA: ["historia", "14-15lat", "historia_powszechna"],
	
	# Przyroda
	Kategoria.ZWIERZĘTA: ["przyroda", "10-11lat", "zwierzeta"],
	Kategoria.ROŚLINY: ["przyroda", "10-11lat", "rosliny"],
	Kategoria.CIAŁO_CZŁOWIEKA: ["przyroda", "12-13lat", "cialo_czlowieka"],
	Kategoria.FIZYKA_PODSTAWY: ["przyroda", "12-13lat", "fizyka_podstawy"],
	Kategoria.CHEMIA_PODSTAWY: ["przyroda", "14-15lat", "chemia_podstawy"],
	Kategoria.EKOLOGIA: ["przyroda", "14-15lat", "ekologia"],
	
	# Polski
	Kategoria.ORTOGRAFIA: ["polski", "10-11lat", "ortografia"],
	Kategoria.CZĘŚCI_MOWY: ["polski", "10-11lat", "czesci_mowy"],
	Kategoria.GRAMATYKA: ["polski", "12-13lat", "gramatyka"],
	Kategoria.LITERATURA: ["polski", "12-13lat", "literatura"],
	
	# Angielski
	Kategoria.COLORS_NUMBERS: ["angielski", "10-11lat", "colors_numbers"],
	Kategoria.SIMPLE_SENTENCES: ["angielski", "10-11lat", "simple_sentences"],
	Kategoria.VOCABULARY: ["angielski", "12-13lat", "vocabulary"],
	Kategoria.GRAMMAR: ["angielski", "12-13lat", "grammar"]
}

func _ready():
	# Inicjalizuj pusty słownik pytań
	pytania_json = {}
	wczytaj_wszystkie_pytania()

# Funkcja wczytująca pytania z pliku JSON i przekształcająca je do wymaganego formatu
func wczytaj_pytania_json(sciezka_pliku):
	print("Próba wczytania pliku: ", sciezka_pliku)
	
	if not FileAccess.file_exists(sciezka_pliku):
		print("Plik nie istnieje: ", sciezka_pliku)
		return null
	
	var plik = FileAccess.open(sciezka_pliku, FileAccess.READ)
	if not plik:
		print("Nie można otworzyć pliku: ", sciezka_pliku)
		return null
	
	var pytania_sformatowane = {}
	
	var tekst_json = plik.get_as_text()
	plik.close()
	
	if tekst_json.strip_edges() == "":
		print("Plik jest pusty: ", sciezka_pliku)
		return null
	
	var json = JSON.new()
	var error = json.parse(tekst_json)
	if error == OK:
		var dane = json.get_data()
		
		if dane == null:
			print("Dane JSON są null w pliku: ", sciezka_pliku)
			return null
		
		# Przekształć wszystkie pytania do formatu ['Question','GOOD','BAD','BAD']
		for przedmiot in dane:
			pytania_sformatowane[przedmiot] = {}
			
			var przedmiot_data = dane.get(przedmiot)
			if przedmiot_data == null:
				continue
				
			for grupa_wiekowa in przedmiot_data:
				pytania_sformatowane[przedmiot][grupa_wiekowa] = {}
				
				var grupa_data = przedmiot_data.get(grupa_wiekowa)
				if grupa_data == null:
					continue
				
				for kategoria in grupa_data:
					var lista_pytan = []
					
					var kategoria_data = grupa_data.get(kategoria)
					if kategoria_data == null:
						continue
					
					for pytanie in kategoria_data:
						if pytanie == null:
							continue
							
						# Sprawdź czy pytanie ma wymagane pola
						if not pytanie.has("pytanie") or not pytanie.has("poprawna") or not pytanie.has("bledne"):
							print("Pytanie ma brakujące pola w: ", sciezka_pliku)
							continue
						
						var bledne_odpowiedzi = pytanie.get("bledne")
						if bledne_odpowiedzi == null or bledne_odpowiedzi.size() < 2:
							print("Brak wystarczającej liczby błędnych odpowiedzi w: ", sciezka_pliku)
							continue
						
						# Tworzymy pytanie w formacie ['Question','GOOD','BAD','BAD']
						var sformatowane_pytanie = [
							str(pytanie.get("pytanie", "")),
							str(pytanie.get("poprawna", "")),
							str(bledne_odpowiedzi[0] if bledne_odpowiedzi.size() > 0 else ""),
							str(bledne_odpowiedzi[1] if bledne_odpowiedzi.size() > 1 else "")
						]
						lista_pytan.append(sformatowane_pytanie)
					
					pytania_sformatowane[przedmiot][grupa_wiekowa][kategoria] = lista_pytan
		
		return pytania_sformatowane
	else:
		print("Błąd parsowania JSON: ", json.get_error_message(), " w linii ", json.get_error_line(), " w pliku: ", sciezka_pliku)
	
	return null

# Funkcja wczytująca wszystkie pliki z pytaniami
func wczytaj_wszystkie_pytania():
	var pliki_pytan = [
		"res://data/pytania_geografia.json",
		"res://data/pytania_historia.json",
		"res://data/pytania_przyroda.json",
		"res://data/pytania_polski.json",
		"res://data/pytania_angielski.json"
	]
	
	print("Rozpoczynam wczytywanie pytań...")
	
	for plik in pliki_pytan:
		print("Wczytywanie: ", plik)
		var dane = wczytaj_pytania_json(plik)
		if dane != null:
			print("Pomyślnie wczytano: ", plik)
			# Scalamy dane z różnych plików
			for przedmiot in dane:
				if not pytania_json.has(przedmiot):
					pytania_json[przedmiot] = {}
				
				var przedmiot_data = dane.get(przedmiot)
				if przedmiot_data == null:
					continue
				
				for grupa_wiekowa in przedmiot_data:
					if not pytania_json[przedmiot].has(grupa_wiekowa):
						pytania_json[przedmiot][grupa_wiekowa] = {}
					
					var grupa_data = przedmiot_data.get(grupa_wiekowa)
					if grupa_data == null:
						continue
					
					for kategoria in grupa_data:
						var pytania_kategorii = grupa_data.get(kategoria)
						if pytania_kategorii != null:
							pytania_json[przedmiot][grupa_wiekowa][kategoria] = pytania_kategorii
		else:
			print("Nie udało się wczytać: ", plik, " - kontynuuję bez tego pliku")
	
	print("Zakończono wczytywanie pytań. Wczytane przedmioty: ", pytania_json.keys())

# Główna funkcja generująca pytanie - zachowuje kompatybilność z istniejącym kodem
func generate_question(difficulty: int = 2, przedmiot: Przedmiot = Przedmiot.MATEMATYKA) -> Array:
	if przedmiot == Przedmiot.MATEMATYKA:
		# Stary system matematyczny
		if difficulty >= 0 and difficulty < lvl_matematyka.size():
			var dostepne_funkcje = lvl_matematyka[difficulty]
			if dostepne_funkcje.size() > 0:
				var function_reference = dostepne_funkcje[randi() % dostepne_funkcje.size()]
				return function_reference.call()
	
	# Nowy system dla innych przedmiotów
	var pytanie = generate_question_from_subject(difficulty, przedmiot)
	
	# Fallback do matematyki jeśli coś poszło nie tak
	if pytanie == null or pytanie.size() < 4 or pytanie[0] == "Błąd":
		print("Fallback do matematyki z powodu błędu")
		return generuj_pytanie_dodawanie_odejmowanie()
	
	return pytanie

# Nowa funkcja do generowania pytań z określonego przedmiotu
func generate_question_from_subject(difficulty: int, przedmiot: Przedmiot) -> Array:
	if not przedmioty_kategorie.has(przedmiot):
		print("Nieznany przedmiot: ", przedmiot)
		return generuj_pytanie_dodawanie_odejmowanie()
	
	var przedmiot_data = przedmioty_kategorie.get(przedmiot)
	if przedmiot_data == null or not przedmiot_data.has(difficulty):
		print("Nieznany poziom trudności dla przedmiotu: ", difficulty, ", przedmiot: ", przedmiot)
		return generuj_pytanie_dodawanie_odejmowanie()
	
	# Wybieramy losową kategorię z danego poziomu trudności
	var dostepne_kategorie = przedmiot_data.get(difficulty)
	if dostepne_kategorie == null or dostepne_kategorie.size() == 0:
		print("Brak dostępnych kategorii dla przedmiotu: ", przedmiot, ", poziom: ", difficulty)
		return generuj_pytanie_dodawanie_odejmowanie()
	
	var wybrana_kategoria = dostepne_kategorie[randi() % dostepne_kategorie.size()]
	
	var pytanie = pobierz_pytanie_z_kategorii(difficulty, wybrana_kategoria)
	
	# Sprawdź czy pytanie jest prawidłowe
	if pytanie == null or pytanie.size() < 4 or pytanie[0] == "Błąd":
		print("Błąd pytania z kategorii: ", wybrana_kategoria, " - używam fallback")
		return generuj_pytanie_dodawanie_odejmowanie()
	
	return pytanie

# Funkcja pobierająca pytanie z określonej kategorii
func pobierz_pytanie_z_kategorii(difficulty: int, kategoria: Kategoria) -> Array:
	# Sprawdź czy to kategoria matematyczna
	var kategorie_matematyczne = [
		Kategoria.DODAWANIE_ODEJMOWANIE, Kategoria.TABLICZKA_MNOZENIA,
		Kategoria.PODZIELNOSC, Kategoria.PROCENT,
		Kategoria.ZAOKRAGLANIE, Kategoria.POTEGI
	]
	
	if kategoria in kategorie_matematyczne:
		return pobierz_pytanie_matematyczne(kategoria)
	else:
		var pytanie = pobierz_pytanie_z_json(kategoria)
		# Fallback do matematyki jeśli pytanie z JSON jest błędne
		if pytanie == null or pytanie.size() < 4 or pytanie[0] == "Błąd":
			print("Fallback do matematyki z kategorii: ", kategoria)
			return generuj_pytanie_dodawanie_odejmowanie()
		return pytanie

# Funkcja pobierająca pytanie matematyczne (stary system)
func pobierz_pytanie_matematyczne(kategoria: Kategoria) -> Array:
	match kategoria:
		Kategoria.DODAWANIE_ODEJMOWANIE:
			return generuj_pytanie_dodawanie_odejmowanie()
		Kategoria.TABLICZKA_MNOZENIA:
			return generuj_pytanie_tabliczka_mnozenia()
		Kategoria.PODZIELNOSC:
			return generuj_pytanie_podzielnosc()
		Kategoria.PROCENT:
			return generuj_pytanie_procent()
		Kategoria.ZAOKRAGLANIE:
			return generuj_pytanie_zaokraglanie()
		Kategoria.POTEGI:
			return generuj_pytanie_potegi()
		_:
			print("Nieznana kategoria matematyczna: ", kategoria, " - używam dodawania/odejmowania")
			return generuj_pytanie_dodawanie_odejmowanie()

# Funkcja pobierająca pytanie z JSON
func pobierz_pytanie_z_json(kategoria: Kategoria) -> Array:
	if not kategoria_do_json_sciezki.has(kategoria):
		print("Brak mapowania dla kategorii: ", kategoria)
		return ["Błąd", "Brak pytania", "Błąd", "Błąd"]
	
	var sciezka = kategoria_do_json_sciezki.get(kategoria)
	if sciezka == null or sciezka.size() < 3:
		print("Nieprawidłowa ścieżka dla kategorii: ", kategoria)
		return ["Błąd", "Nieprawidłowa ścieżka", "Błąd", "Błąd"]
	
	var przedmiot = sciezka[0]
	var grupa_wiekowa = sciezka[1]
	var nazwa_kategorii = sciezka[2]
	
	if not pytania_json.has(przedmiot):
		print("Brak danych dla przedmiotu: ", przedmiot)
		return ["Błąd", "Brak pytania", "Błąd", "Błąd"]
	
	var przedmiot_data = pytania_json.get(przedmiot)
	if przedmiot_data == null:
		print("Dane przedmiotu są null: ", przedmiot)
		return ["Błąd", "Brak danych przedmiotu", "Błąd", "Błąd"]
	
	if not przedmiot_data.has(grupa_wiekowa):
		print("Brak danych dla grupy wiekowej: ", grupa_wiekowa)
		return ["Błąd", "Brak pytania", "Błąd", "Błąd"]
	
	var grupa_data = przedmiot_data.get(grupa_wiekowa)
	if grupa_data == null:
		print("Dane grupy wiekowej są null: ", grupa_wiekowa)
		return ["Błąd", "Brak danych grupy", "Błąd", "Błąd"]
	
	if not grupa_data.has(nazwa_kategorii):
		print("Brak danych dla kategorii: ", nazwa_kategorii)
		return ["Błąd", "Brak pytania", "Błąd", "Błąd"]
	
	var lista_pytan = grupa_data.get(nazwa_kategorii)
	if lista_pytan == null or lista_pytan.size() == 0:
		print("Brak pytań w kategorii: ", nazwa_kategorii)
		return ["Błąd", "Brak pytań w kategorii", "Błąd", "Błąd"]
	
	var indeks = randi() % lista_pytan.size()
	return lista_pytan[indeks]

# Funkcja do pobierania dostępnych przedmiotów
func get_available_subjects() -> Array:
	return [
		Przedmiot.MATEMATYKA,
		Przedmiot.GEOGRAFIA,
		Przedmiot.HISTORIA,
		Przedmiot.PRZYRODA,
		Przedmiot.POLSKI,
		Przedmiot.ANGIELSKI
	]

# Funkcja do pobierania nazw przedmiotów
func get_subject_name(przedmiot: Przedmiot) -> String:
	match przedmiot:
		Przedmiot.MATEMATYKA: return "Matematyka"
		Przedmiot.GEOGRAFIA: return "Geografia"
		Przedmiot.HISTORIA: return "Historia"
		Przedmiot.PRZYRODA: return "Przyroda"
		Przedmiot.POLSKI: return "Język Polski"
		Przedmiot.ANGIELSKI: return "Język Angielski"
		_: return "Nieznany"

# Funkcja do pobierania dostępnych kategorii dla danego przedmiotu i poziomu
func get_available_categories(przedmiot: Przedmiot, difficulty: int) -> Array:
	if przedmioty_kategorie.has(przedmiot) and przedmioty_kategorie[przedmiot].has(difficulty):
		return przedmioty_kategorie[przedmiot][difficulty]
	return []

# Funkcja do pobierania nazwy kategorii
func get_category_name(kategoria: Kategoria) -> String:
	match kategoria:
		# Matematyka
		Kategoria.DODAWANIE_ODEJMOWANIE: return "Dodawanie i odejmowanie"
		Kategoria.TABLICZKA_MNOZENIA: return "Tabliczka mnożenia"
		Kategoria.PODZIELNOSC: return "Podzielność"
		Kategoria.PROCENT: return "Procenty"
		Kategoria.ZAOKRAGLANIE: return "Zaokrąglanie"
		Kategoria.POTEGI: return "Potęgi"
		
		# Geografia
		Kategoria.MAPA_SWIATA: return "Mapa świata"
		Kategoria.UKSZTALTOWANIE_TERENU: return "Ukształtowanie terenu"
		Kategoria.KLIMAT: return "Klimat"
		Kategoria.GEOGRAFIA_POLSKI: return "Geografia Polski"
		Kategoria.GEOLOGIA: return "Geologia"
		Kategoria.GEOGRAFIA_GOSPODARKI: return "Geografia gospodarki"
		
		# Historia
		Kategoria.HISTORIA_STAROŻYTNA: return "Historia starożytna"
		Kategoria.HISTORIA_ŚREDNIOWIECZA: return "Historia średniowiecza"
		Kategoria.HISTORIA_POLSKI: return "Historia Polski"
		Kategoria.HISTORIA_NOWOŻYTNA: return "Historia nowożytna"
		Kategoria.HISTORIA_WSPÓŁCZESNA: return "Historia współczesna"
		Kategoria.HISTORIA_POWSZECHNA: return "Historia powszechna"
		
		# Przyroda
		Kategoria.ZWIERZĘTA: return "Zwierzęta"
		Kategoria.ROŚLINY: return "Rośliny"
		Kategoria.CIAŁO_CZŁOWIEKA: return "Ciało człowieka"
		Kategoria.FIZYKA_PODSTAWY: return "Podstawy fizyki"
		Kategoria.CHEMIA_PODSTAWY: return "Podstawy chemii"
		Kategoria.EKOLOGIA: return "Ekologia"
		
		# Polski
		Kategoria.ORTOGRAFIA: return "Ortografia"
		Kategoria.GRAMATYKA: return "Gramatyka"
		Kategoria.LITERATURA: return "Literatura"
		Kategoria.CZĘŚCI_MOWY: return "Części mowy"
		
		# Angielski
		Kategoria.VOCABULARY: return "Vocabulary"
		Kategoria.GRAMMAR: return "Grammar"
		Kategoria.SIMPLE_SENTENCES: return "Simple sentences"
		Kategoria.COLORS_NUMBERS: return "Colors & Numbers"
		
		_: return "Nieznana kategoria"

# Funkcja sprawdzająca ile pytań jest dostępnych w danej kategorii
func get_questions_count_in_category(kategoria: Kategoria) -> int:
	if kategoria_do_json_sciezki.has(kategoria):
		var sciezka = kategoria_do_json_sciezki.get(kategoria)
		if sciezka == null or sciezka.size() < 3:
			return 0
			
		var przedmiot = sciezka[0]
		var grupa_wiekowa = sciezka[1]
		var nazwa_kategorii = sciezka[2]
		
		var przedmiot_data = pytania_json.get(przedmiot)
		if przedmiot_data == null:
			return 0
			
		var grupa_data = przedmiot_data.get(grupa_wiekowa)
		if grupa_data == null:
			return 0
			
		var kategoria_data = grupa_data.get(nazwa_kategorii)
		if kategoria_data == null:
			return 0
			
		return kategoria_data.size()
	
	# Dla kategorii matematycznych zwracamy przybliżoną liczbę
	var kategorie_matematyczne = [
		Kategoria.DODAWANIE_ODEJMOWANIE, Kategoria.TABLICZKA_MNOZENIA,
		Kategoria.PODZIELNOSC, Kategoria.PROCENT,
		Kategoria.ZAOKRAGLANIE, Kategoria.POTEGI
	]
	
	if kategoria in kategorie_matematyczne:
		match kategoria:
			Kategoria.TABLICZKA_MNOZENIA: return 100
			Kategoria.DODAWANIE_ODEJMOWANIE: return 2000
			Kategoria.PODZIELNOSC: return 1200
			Kategoria.PROCENT: return 48
			Kategoria.ZAOKRAGLANIE: return 500
			Kategoria.POTEGI: return 60
	
	return 0

# Istniejące funkcje matematyczne (pozostają bez zmian)

# [Tutaj wstawione wszystkie istniejące funkcje matematyczne bez zmian]

# Funkcja generująca pytanie o dodawanie i odejmowanie w zakresie 50
func generuj_pytanie_dodawanie_odejmowanie():
	# [Kod funkcji pozostaje bez zmian - jest już w oryginalnym pliku]
	var czy_dodawanie = randi() % 2 == 0
	
	var liczba1
	var liczba2
	var poprawna_odpowiedz
	
	if czy_dodawanie:
		liczba1 = randi() % 30 + 1
		liczba2 = randi() % (50 - liczba1 + 1) + 1
		poprawna_odpowiedz = liczba1 + liczba2
		
	else:
		liczba1 = randi() % 50 + 1
		liczba2 = randi() % liczba1 + 1
		poprawna_odpowiedz = liczba1 - liczba2
	
	var pytanie = str(liczba1) + (" + " if czy_dodawanie else " - ") + str(liczba2) + " = ?"
	
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	var typ_bledu1 = randi() % 3
	
	if typ_bledu1 == 0:
		bledna_odpowiedz1 = poprawna_odpowiedz + 1
	elif typ_bledu1 == 1:
		bledna_odpowiedz1 = poprawna_odpowiedz - 1
	else:
		if czy_dodawanie:
			bledna_odpowiedz1 = liczba1 - liczba2
			if bledna_odpowiedz1 <= 0:
				bledna_odpowiedz1 = poprawna_odpowiedz + 2
		else:
			bledna_odpowiedz1 = liczba1 + liczba2
	
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + 2
	
	var typ_bledu2 = randi() % 4
	
	while typ_bledu2 == typ_bledu1 and typ_bledu1 < 3:
		typ_bledu2 = randi() % 4
	
	if typ_bledu2 == 0:
		bledna_odpowiedz2 = poprawna_odpowiedz + 1
	elif typ_bledu2 == 1:
		bledna_odpowiedz2 = poprawna_odpowiedz - 1
	elif typ_bledu2 == 2:
		if czy_dodawanie:
			bledna_odpowiedz2 = liczba1 - liczba2
			if bledna_odpowiedz2 <= 0:
				bledna_odpowiedz2 = poprawna_odpowiedz + 3
		else:
			bledna_odpowiedz2 = liczba1 + liczba2
	else:
		if czy_dodawanie:
			bledna_odpowiedz2 = poprawna_odpowiedz + 2
		else:
			bledna_odpowiedz2 = liczba2 - liczba1
			if bledna_odpowiedz2 <= 0:
				bledna_odpowiedz2 = poprawna_odpowiedz + 3
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz + 3
	
	if bledna_odpowiedz2 == bledna_odpowiedz1:
		bledna_odpowiedz2 = bledna_odpowiedz1 + 1
		
		if bledna_odpowiedz2 == poprawna_odpowiedz:
			bledna_odpowiedz2 = bledna_odpowiedz1 + 2
	
	poprawna_odpowiedz = str(poprawna_odpowiedz)
	bledna_odpowiedz1 = str(bledna_odpowiedz1)
	bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]

func generuj_pytanie_tabliczka_mnozenia(min_liczba = 1, max_liczba = 10):
	var liczba1 = randi() % (max_liczba - min_liczba + 1) + min_liczba
	var liczba2 = randi() % (max_liczba - min_liczba + 1) + min_liczba
	
	var poprawna_odpowiedz = liczba1 * liczba2
	
	var pytanie = "Ile wynosi " + str(liczba1) + " × " + str(liczba2) + "?"
	
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	while true:
		var odchylenie = randi() % 5 + 1
		if randi() % 2 == 0:
			bledna_odpowiedz1 = poprawna_odpowiedz + odchylenie
		else:
			bledna_odpowiedz1 = max(1, poprawna_odpowiedz - odchylenie)
		
		if bledna_odpowiedz1 != poprawna_odpowiedz:
			break
	
	while true:
		var odchylenie = randi() % 5 + 1
		if randi() % 2 == 0:
			bledna_odpowiedz2 = poprawna_odpowiedz + odchylenie
		else:
			bledna_odpowiedz2 = max(1, poprawna_odpowiedz - odchylenie)
		
		if bledna_odpowiedz2 != poprawna_odpowiedz and bledna_odpowiedz2 != bledna_odpowiedz1:
			break
	
	return [pytanie, str(poprawna_odpowiedz), str(bledna_odpowiedz1), str(bledna_odpowiedz2)]

func generuj_pytanie_podzielnosc(min_liczba = 10, max_liczba = 1000):
	var dzielniki = [2, 3, 4, 5, 9, 10]
	
	var dzielnik = dzielniki[randi() % dzielniki.size()]
	
	var pytanie = "Która z liczb jest podzielna przez " + str(dzielnik) + "?"
	
	var poprawna_liczba
	
	match dzielnik:
		2:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 2) + min_liczba / 2) * 2
		3:
			poprawna_liczba = randi() % (max_liczba - min_liczba) + min_liczba
			while poprawna_liczba % 3 != 0:
				poprawna_liczba += 1
				if poprawna_liczba > max_liczba:
					poprawna_liczba = min_liczba
		4:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 4) + min_liczba / 4) * 4
		5:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 5) + min_liczba / 5) * 5
		9:
			poprawna_liczba = randi() % (max_liczba - min_liczba) + min_liczba
			while poprawna_liczba % 9 != 0:
				poprawna_liczba += 1
				if poprawna_liczba > max_liczba:
					poprawna_liczba = min_liczba
		10:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 10) + min_liczba / 10) * 10
	
	var bledna_liczba1 = generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, [poprawna_liczba])
	var bledna_liczba2 = generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, [poprawna_liczba, bledna_liczba1])
	
	return [pytanie, str(poprawna_liczba), str(bledna_liczba1), str(bledna_liczba2)]

func generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, wykluczone_liczby = []):
	var liczba
	var max_prob = 100
	var prob = 0
	
	while prob < max_prob:
		prob += 1
		
		liczba = randi() % (max_liczba - min_liczba) + min_liczba
		
		if liczba in wykluczone_liczby:
			continue
		
		if liczba % dzielnik != 0:
			return liczba
	
	liczba = min_liczba
	while true:
		if not (liczba in wykluczone_liczby) and liczba % dzielnik != 0:
			return liczba
		liczba += 1
		if liczba > max_liczba:
			liczba = min_liczba

func generuj_pytanie_procent():
	var procenty = [1, 10, 20, 25, 50, 75, 100]
	
	var procent = procenty[randi() % procenty.size()]
	
	var liczby_bazowe = [20, 40, 50, 100, 200, 400, 500, 1000]
	var liczba = liczby_bazowe[randi() % liczby_bazowe.size()]
	
	var poprawna_odpowiedz = (liczba * procent) / 100
	
	var pytanie = "Ile to jest " + str(procent) + "% z " + str(liczba) + "?"
	
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	var typ_bledu = randi() % 3
	
	if typ_bledu == 0 && liczba < 100:
		bledna_odpowiedz1 = (procent * liczba) / 100
	elif typ_bledu == 1:
		bledna_odpowiedz1 = liczba + procent
	else:
		bledna_odpowiedz1 = liczba * procent
	
	if poprawna_odpowiedz >= 10:
		bledna_odpowiedz2 = poprawna_odpowiedz + (randi() % 5 + 1)
	else:
		bledna_odpowiedz2 = poprawna_odpowiedz + (randi() % 3 + 1)
	
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + 10
	
	if bledna_odpowiedz2 == poprawna_odpowiedz || bledna_odpowiedz2 == bledna_odpowiedz1:
		bledna_odpowiedz2 = poprawna_odpowiedz - 5
		if bledna_odpowiedz2 <= 0:
			bledna_odpowiedz2 = poprawna_odpowiedz * 2
	
	return [pytanie, str(poprawna_odpowiedz), str(bledna_odpowiedz1), str(bledna_odpowiedz2)]

func generuj_pytanie_zaokraglanie():
	var typy_zaokraglania = [
		"do setek",
		"do dziesiątek",
		"do jedności",
		"do części dziesiętnych",
		"do części setnych"
	]
	
	var indeks_typu = randi() % typy_zaokraglania.size()
	var typ_zaokraglania = typy_zaokraglania[indeks_typu]
	
	var liczba
	var poprawna_odpowiedz
	
	match indeks_typu:
		0:
			liczba = randi() % 900 + 100
			poprawna_odpowiedz = int(round(liczba / 100.0)) * 100
		
		1:
			liczba = randi() % 90 + 10
			poprawna_odpowiedz = int(round(liczba / 10.0)) * 10
		
		2:
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 99 + 1
			liczba = calosc + (ulamek / 100.0)
			liczba = snapped(liczba, 0.01)
			poprawna_odpowiedz = round(liczba)
		
		3:
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 99 + 1
			liczba = calosc + (ulamek / 100.0)
			liczba = snapped(liczba, 0.01)
			poprawna_odpowiedz = snapped(round(liczba * 10) / 10.0, 0.1)
		
		4:
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 999 + 1
			liczba = calosc + (ulamek / 1000.0)
			liczba = snapped(liczba, 0.001)
			poprawna_odpowiedz = snapped(round(liczba * 100) / 100.0, 0.01)
	
	var liczba_tekst = str(liczba).replace(".", ",")
	
	var pytanie = "Zaokrąglij liczbę " + liczba_tekst + " " + typ_zaokraglania + "."
	
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	match indeks_typu:
		0, 1:
			bledna_odpowiedz1 = poprawna_odpowiedz - (100 if indeks_typu == 0 else 10)
			bledna_odpowiedz2 = poprawna_odpowiedz + (100 if indeks_typu == 0 else 10)
			
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + 50 if indeks_typu == 0 else poprawna_odpowiedz + 5
			
			if bledna_odpowiedz2 == poprawna_odpowiedz:
				bledna_odpowiedz2 = poprawna_odpowiedz - 50 if indeks_typu == 0 else poprawna_odpowiedz - 5
		
		2:
			bledna_odpowiedz1 = floor(liczba)
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + 1
			
			bledna_odpowiedz2 = ceil(liczba)
			if bledna_odpowiedz2 == poprawna_odpowiedz:
				bledna_odpowiedz2 = poprawna_odpowiedz - 1
		
		3, 4:
			var blad_kierunku = 0.1 if indeks_typu == 3 else 0.01
			
			if randi() % 2 == 0:
				bledna_odpowiedz1 = snapped(floor(liczba * (10 if indeks_typu == 3 else 100)) / (10.0 if indeks_typu == 3 else 100.0), blad_kierunku)
			else:
				bledna_odpowiedz1 = snapped(round(liczba * (100 if indeks_typu == 3 else 1000)) / (100.0 if indeks_typu == 3 else 1000.0), blad_kierunku / 10)
			
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + blad_kierunku
			
			if randi() % 2 == 0:
				bledna_odpowiedz2 = snapped(ceil(liczba * (10 if indeks_typu == 3 else 100)) / (10.0 if indeks_typu == 3 else 100.0), blad_kierunku)
			else:
				bledna_odpowiedz2 = snapped(round(liczba * (1 if indeks_typu == 3 else 10)) / (1.0 if indeks_typu == 3 else 10.0), blad_kierunku * 10)
			
			if bledna_odpowiedz2 == poprawna_odpowiedz or bledna_odpowiedz2 == bledna_odpowiedz1:
				bledna_odpowiedz2 = poprawna_odpowiedz - blad_kierunku
	
	if indeks_typu == 3 or indeks_typu == 4:
		poprawna_odpowiedz = str(poprawna_odpowiedz).replace(".", ",")
		bledna_odpowiedz1 = str(bledna_odpowiedz1).replace(".", ",")
		bledna_odpowiedz2 = str(bledna_odpowiedz2).replace(".", ",")
	else:
		poprawna_odpowiedz = str(poprawna_odpowiedz)
		bledna_odpowiedz1 = str(bledna_odpowiedz1)
		bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	if bledna_odpowiedz1 == bledna_odpowiedz2:
		if indeks_typu <= 1:
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz2 = str(int(bledna_odpowiedz2) + mnoznik * 2)
		elif indeks_typu == 2:
			bledna_odpowiedz2 = str(int(bledna_odpowiedz2) + 2)
		else:
			var wartosc = float(bledna_odpowiedz2.replace(",", "."))
			var nowa_wartosc = wartosc + (0.2 if indeks_typu == 3 else 0.02)
			bledna_odpowiedz2 = str(nowa_wartosc).replace(".", ",")
	
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		if indeks_typu <= 1:
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz1 = str(int(poprawna_odpowiedz) + mnoznik)
		elif indeks_typu == 2:
			bledna_odpowiedz1 = str(int(poprawna_odpowiedz) + 1)
		else:
			var wartosc = float(poprawna_odpowiedz.replace(",", "."))
			var nowa_wartosc = wartosc + (0.1 if indeks_typu == 3 else 0.01)
			bledna_odpowiedz1 = str(nowa_wartosc).replace(".", ",")
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		if indeks_typu <= 1:
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz2 = str(int(poprawna_odpowiedz) - mnoznik)
		elif indeks_typu == 2:
			bledna_odpowiedz2 = str(int(poprawna_odpowiedz) - 1)
		else:
			var wartosc = float(poprawna_odpowiedz.replace(",", "."))
			var nowa_wartosc = wartosc - (0.1 if indeks_typu == 3 else 0.01)
			bledna_odpowiedz2 = str(nowa_wartosc).replace(".", ",")
	
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]

func liczba_na_wykladnik_unicode(liczba):
	var cyfry_unicode = {
		"0": "⁰",
		"1": "¹",
		"2": "²",
		"3": "³",
		"4": "⁴",
		"5": "⁵",
		"6": "⁶",
		"7": "⁷",
		"8": "⁸",
		"9": "⁹",
		"-": "⁻"
	}
	
	var wykladnik_tekst = str(liczba)
	var wynik = ""
	
	for i in range(wykladnik_tekst.length()):
		var znak = wykladnik_tekst[i]
		if cyfry_unicode.has(znak):
			wynik += cyfry_unicode[znak]
		else:
			wynik += znak
	
	return wynik

func generuj_pytanie_potegi():
	var min_podstawa = -10
	var max_podstawa = 10
	var min_wykladnik = 2
	var max_wykladnik = 4
	
	var podstawa = randi() % (max_podstawa - min_podstawa + 1) + min_podstawa
	var wykladnik = randi() % (max_wykladnik - min_wykladnik + 1) + min_wykladnik
	
	if podstawa == 0:
		podstawa = randi() % 10 + 1
	
	var poprawna_odpowiedz = pow(podstawa, wykladnik)
	
	var pytanie
	var wykladnik_unicode = liczba_na_wykladnik_unicode(wykladnik)
	
	if podstawa < 0:
		pytanie = "Ile wynosi (" + str(podstawa) + ")" + wykladnik_unicode + "?"
	else:
		pytanie = "Ile wynosi " + str(podstawa) + wykladnik_unicode + "?"
	
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	bledna_odpowiedz1 = podstawa * wykladnik
	
	if podstawa < 0 and wykladnik % 2 == 0:
		bledna_odpowiedz2 = -poprawna_odpowiedz
	elif podstawa < 0 and wykladnik % 2 == 1:
		bledna_odpowiedz2 = -poprawna_odpowiedz
	else:
		if randi() % 2 == 0:
			bledna_odpowiedz2 = pow(podstawa, wykladnik - 1)
		else:
			bledna_odpowiedz2 = pow(podstawa, wykladnik + 1)
	
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + (1 if poprawna_odpowiedz >= 0 else -1)
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz + (2 if poprawna_odpowiedz >= 0 else -2)
	
	if bledna_odpowiedz1 == bledna_odpowiedz2:
		bledna_odpowiedz2 = bledna_odpowiedz1 + (3 if bledna_odpowiedz1 >= 0 else -3)
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz * 2
	
	poprawna_odpowiedz = str(poprawna_odpowiedz)
	bledna_odpowiedz1 = str(bledna_odpowiedz1)
	bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]
