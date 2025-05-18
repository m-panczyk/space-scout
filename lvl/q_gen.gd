extends Node

#func _run() -> void:
	#print(generate_question())

############################################
var lvl = [
	[generuj_pytanie_dodawanie_odejmowanie,generuj_pytanie_tabliczka_mnozenia],
	[generuj_pytanie_podzielnosc,generuj_pytanie_procent],
	[generuj_pytanie_zaokraglanie,generuj_pytanie_potegi]
]

func generate_question(difficulty:int = 2) -> Array:
	var function_reference = lvl[difficulty][randi() % lvl[difficulty].size()]
	return function_reference.call()
############################################
# Funkcja generująca pytanie o dodawanie i odejmowanie w zakresie 50
func generuj_pytanie_dodawanie_odejmowanie():
	# Decydujemy, czy pytanie będzie o dodawanie czy odejmowanie
	var czy_dodawanie = randi() % 2 == 0
	
	var liczba1
	var liczba2
	var poprawna_odpowiedz
	
	if czy_dodawanie:
		# Dla dodawania wybieramy liczby tak, aby suma była ≤ 50
		liczba1 = randi() % 30 + 1  # Liczba od 1 do 30
		liczba2 = randi() % (50 - liczba1 + 1) + 1  # Liczba od 1 do (50-liczba1)
		poprawna_odpowiedz = liczba1 + liczba2
		
	else:
		# Dla odejmowania wybieramy pierwszą liczbę ≤ 50, a drugą mniejszą od pierwszej
		liczba1 = randi() % 50 + 1  # Liczba od 1 do 50
		liczba2 = randi() % liczba1 + 1  # Liczba od 1 do liczba1
		poprawna_odpowiedz = liczba1 - liczba2
	
	# Tworzymy pytanie
	var pytanie = str(liczba1) + (" + " if czy_dodawanie else " - ") + str(liczba2) + " = ?"
	
	# Generujemy błędne odpowiedzi
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	# Losowo wybieramy rodzaj pierwszego błędu
	var typ_bledu1 = randi() % 3
	
	if typ_bledu1 == 0:
		# Błąd o +/- 1 (typowy błąd o jeden)
		bledna_odpowiedz1 = poprawna_odpowiedz + 1
	elif typ_bledu1 == 1:
		# Błąd o +/- 1 (typowy błąd o jeden w drugą stronę)
		bledna_odpowiedz1 = poprawna_odpowiedz - 1
	else:
		# Odwrotna operacja (dodawanie zamiast odejmowania lub odwrotnie)
		if czy_dodawanie:
			bledna_odpowiedz1 = liczba1 - liczba2
			if bledna_odpowiedz1 <= 0:  # Unikamy ujemnych odpowiedzi
				bledna_odpowiedz1 = poprawna_odpowiedz + 2
		else:
			bledna_odpowiedz1 = liczba1 + liczba2
	
	# Upewniamy się, że pierwsza błędna odpowiedź jest różna od poprawnej
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + 2
	
	# Losowo wybieramy rodzaj drugiego błędu, upewniając się, że jest inny niż pierwszy
	var typ_bledu2 = randi() % 4
	
	# Upewnijmy się, że drugi typ błędu jest inny niż pierwszy (jeśli pierwszy jest < 3)
	while typ_bledu2 == typ_bledu1 and typ_bledu1 < 3:
		typ_bledu2 = randi() % 4
	
	if typ_bledu2 == 0:
		# Błąd o +/- 1 (typowy błąd o jeden)
		bledna_odpowiedz2 = poprawna_odpowiedz + 1
	elif typ_bledu2 == 1:
		# Błąd o +/- 1 (typowy błąd o jeden w drugą stronę)
		bledna_odpowiedz2 = poprawna_odpowiedz - 1
	elif typ_bledu2 == 2:
		# Odwrotna operacja (dodawanie zamiast odejmowania lub odwrotnie)
		if czy_dodawanie:
			bledna_odpowiedz2 = liczba1 - liczba2
			if bledna_odpowiedz2 <= 0:  # Unikamy ujemnych odpowiedzi
				bledna_odpowiedz2 = poprawna_odpowiedz + 3
		else:
			bledna_odpowiedz2 = liczba1 + liczba2
	else:
		# Inny typowy błąd: zamiana liczb przy odejmowaniu lub błąd o +/- 2
		if czy_dodawanie:
			bledna_odpowiedz2 = poprawna_odpowiedz + 2
		else:
			# Zamiana liczb przy odejmowaniu (typowy błąd: 7-3=4, ale uczeń liczy 3-7=-4)
			bledna_odpowiedz2 = liczba2 - liczba1
			if bledna_odpowiedz2 <= 0:  # Unikamy ujemnych odpowiedzi dla początkujących uczniów
				bledna_odpowiedz2 = poprawna_odpowiedz + 3
	
	# Upewniamy się, że druga błędna odpowiedź jest różna od poprawnej i pierwszej błędnej
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz + 3
	
	if bledna_odpowiedz2 == bledna_odpowiedz1:
		bledna_odpowiedz2 = bledna_odpowiedz1 + 1
		
		# Dodatkowe sprawdzenie, czy po dodaniu 1 nie jest równa poprawnej
		if bledna_odpowiedz2 == poprawna_odpowiedz:
			bledna_odpowiedz2 = bledna_odpowiedz1 + 2
	
	# Konwertujemy odpowiedzi na stringi
	poprawna_odpowiedz = str(poprawna_odpowiedz)
	bledna_odpowiedz1 = str(bledna_odpowiedz1)
	bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]


func generuj_pytanie_tabliczka_mnozenia(min_liczba = 1, max_liczba = 10):
	# Generowanie dwóch losowych liczb z określonego zakresu
	var liczba1 = randi() % (max_liczba - min_liczba + 1) + min_liczba
	var liczba2 = randi() % (max_liczba - min_liczba + 1) + min_liczba
	
	# Obliczenie poprawnej odpowiedzi
	var poprawna_odpowiedz = liczba1 * liczba2
	
	# Tworzenie pytania
	var pytanie = "Ile wynosi " + str(liczba1) + " × " + str(liczba2) + "?"
	
	# Generowanie błędnych odpowiedzi
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	# Generujemy pierwszą błędną odpowiedź
	while true:
		var odchylenie = randi() % 5 + 1  # Odchylenie od 1 do 5
		if randi() % 2 == 0:
			bledna_odpowiedz1 = poprawna_odpowiedz + odchylenie
		else:
			bledna_odpowiedz1 = max(1, poprawna_odpowiedz - odchylenie)
		
		# Upewniamy się, że błędna odpowiedź różni się od poprawnej
		if bledna_odpowiedz1 != poprawna_odpowiedz:
			break
	
	# Generujemy drugą błędną odpowiedź
	while true:
		var odchylenie = randi() % 5 + 1  # Odchylenie od 1 do 5
		if randi() % 2 == 0:
			bledna_odpowiedz2 = poprawna_odpowiedz + odchylenie
		else:
			bledna_odpowiedz2 = max(1, poprawna_odpowiedz - odchylenie)
		
		# Upewniamy się, że druga błędna odpowiedź różni się od poprawnej i pierwszej błędnej
		if bledna_odpowiedz2 != poprawna_odpowiedz and bledna_odpowiedz2 != bledna_odpowiedz1:
			break
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, str(poprawna_odpowiedz), str(bledna_odpowiedz1), str(bledna_odpowiedz2)]

# Funkcja generująca pytanie o podzielność liczb
func generuj_pytanie_podzielnosc(min_liczba = 10, max_liczba = 1000):
	# Lista dzielników
	var dzielniki = [2, 3, 4, 5, 9, 10]
	
	# Wybieramy losowy dzielnik
	var dzielnik = dzielniki[randi() % dzielniki.size()]
	
	# Pytanie
	var pytanie = "Która z liczb jest podzielna przez " + str(dzielnik) + "?"
	
	# Generujemy liczbę podzielną przez wybrany dzielnik (poprawna odpowiedź)
	var poprawna_liczba
	
	# Generujemy liczbę podzielną przez wybrany dzielnik
	match dzielnik:
		2:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 2) + min_liczba / 2) * 2
		3:
			# Generujemy losową liczbę
			poprawna_liczba = randi() % (max_liczba - min_liczba) + min_liczba
			# Dostosowujemy ją, aby była podzielna przez 3
			while poprawna_liczba % 3 != 0:
				poprawna_liczba += 1
				if poprawna_liczba > max_liczba:
					poprawna_liczba = min_liczba
		4:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 4) + min_liczba / 4) * 4
		5:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 5) + min_liczba / 5) * 5
		9:
			# Generujemy losową liczbę
			poprawna_liczba = randi() % (max_liczba - min_liczba) + min_liczba
			# Dostosowujemy ją, aby była podzielna przez 9
			while poprawna_liczba % 9 != 0:
				poprawna_liczba += 1
				if poprawna_liczba > max_liczba:
					poprawna_liczba = min_liczba
		10:
			poprawna_liczba = (randi() % ((max_liczba - min_liczba) / 10) + min_liczba / 10) * 10
	
	# Generujemy dwie niepodzielne liczby (błędne odpowiedzi)
	var bledna_liczba1 = generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, [poprawna_liczba])
	var bledna_liczba2 = generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, [poprawna_liczba, bledna_liczba1])
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, str(poprawna_liczba), str(bledna_liczba1), str(bledna_liczba2)]

# Funkcja pomocnicza do generowania liczby niepodzielnej przez dzielnik
func generuj_niepodzielna_liczbe(dzielnik, min_liczba, max_liczba, wykluczone_liczby = []):
	var liczba
	var max_prob = 100  # Zabezpieczenie przed nieskończoną pętlą
	var prob = 0
	
	while prob < max_prob:
		prob += 1
		
		# Generujemy losową liczbę z zakresu
		liczba = randi() % (max_liczba - min_liczba) + min_liczba
		
		# Sprawdzamy, czy liczba nie jest na liście wykluczonych
		if liczba in wykluczone_liczby:
			continue
		
		# Sprawdzamy, czy liczba NIE jest podzielna przez dzielnik
		if liczba % dzielnik != 0:
			return liczba
	
	# Jeśli nie uda się znaleźć losowo, generujemy deterministycznie
	liczba = min_liczba
	while true:
		if not (liczba in wykluczone_liczby) and liczba % dzielnik != 0:
			return liczba
		liczba += 1
		if liczba > max_liczba:
			liczba = min_liczba

# Funkcja generująca pytanie o procent z liczby dla szkoły podstawowej
func generuj_pytanie_procent():
	# Tablica z łatwymi do obliczenia procentami dla dzieci
	var procenty = [1, 10, 20, 25, 50, 75, 100]
	
	# Wybieramy losowy procent
	var procent = procenty[randi() % procenty.size()]
	
	# Generujemy liczbę, która będzie łatwa do obliczenia
	var liczby_bazowe = [20, 40, 50, 100, 200, 400, 500, 1000]
	var liczba = liczby_bazowe[randi() % liczby_bazowe.size()]
	
	# Obliczamy poprawną odpowiedź (procent z liczby)
	var poprawna_odpowiedz = (liczba * procent) / 100
	
	# Tworzymy pytanie
	var pytanie = "Ile to jest " + str(procent) + "% z " + str(liczba) + "?"
	
	# Generujemy błędne odpowiedzi
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	# Pierwsza błędna odpowiedź - zamiana procentu z liczbą (np. 200% z 10 zamiast 10% z 200)
	# lub inna typowa pomyłka
	var typ_bledu = randi() % 3
	
	if typ_bledu == 0 && liczba < 100:  # Zamiana miejscami, ale tylko gdy liczba jest sensowna jako procent
		bledna_odpowiedz1 = (procent * liczba) / 100
	elif typ_bledu == 1:  # Dodanie procentu do liczby zamiast obliczenia procentu
		bledna_odpowiedz1 = liczba + procent
	else:  # Pomnożenie liczby przez procent bez dzielenia przez 100
		bledna_odpowiedz1 = liczba * procent
	
	# Druga błędna odpowiedź - niewielka modyfikacja poprawnej odpowiedzi
	if poprawna_odpowiedz >= 10:
		bledna_odpowiedz2 = poprawna_odpowiedz + (randi() % 5 + 1)  # Dodajemy 1-5
	else:
		bledna_odpowiedz2 = poprawna_odpowiedz + (randi() % 3 + 1)  # Dodajemy 1-3
	
	# Upewniamy się, że błędne odpowiedzi nie są takie same jak poprawna
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + 10
	
	if bledna_odpowiedz2 == poprawna_odpowiedz || bledna_odpowiedz2 == bledna_odpowiedz1:
		bledna_odpowiedz2 = poprawna_odpowiedz - 5
		if bledna_odpowiedz2 <= 0:  # Nie chcemy ujemnych odpowiedzi
			bledna_odpowiedz2 = poprawna_odpowiedz * 2
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, str(poprawna_odpowiedz), str(bledna_odpowiedz1), str(bledna_odpowiedz2)]
# Funkcja generująca pytanie o zaokrąglanie liczb
# Funkcja generująca pytanie o zaokrąglanie liczb
func generuj_pytanie_zaokraglanie():
	# Definiujemy typy zaokrąglania
	var typy_zaokraglania = [
		"do setek",
		"do dziesiątek",
		"do jedności",
		"do części dziesiętnych",
		"do części setnych"
	]
	
	# Wybieramy losowy typ zaokrąglania
	var indeks_typu = randi() % typy_zaokraglania.size()
	var typ_zaokraglania = typy_zaokraglania[indeks_typu]
	
	# Generujemy odpowiednią liczbę do zaokrąglenia
	var liczba
	var poprawna_odpowiedz
	
	match indeks_typu:
		0: # do setek
			# Generujemy liczbę z przedziału 100-999
			liczba = randi() % 900 + 100
			# Obliczamy poprawne zaokrąglenie
			poprawna_odpowiedz = int(round(liczba / 100.0)) * 100
		
		1: # do dziesiątek
			# Generujemy liczbę z przedziału 10-99
			liczba = randi() % 90 + 10
			# Obliczamy poprawne zaokrąglenie
			poprawna_odpowiedz = int(round(liczba / 10.0)) * 10
		
		2: # do jedności (całości)
			# Generujemy liczbę z częścią ułamkową
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 99 + 1
			liczba = calosc + (ulamek / 100.0)
			liczba = snapped(liczba, 0.01) # Zaokrąglamy do 2 miejsc po przecinku dla czytelności
			# Obliczamy poprawne zaokrąglenie
			poprawna_odpowiedz = round(liczba)
		
		3: # do części dziesiętnych
			# Generujemy liczbę z 2 miejscami po przecinku
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 99 + 1
			liczba = calosc + (ulamek / 100.0)
			liczba = snapped(liczba, 0.01) # Zaokrąglamy do 2 miejsc po przecinku dla czytelności
			# Obliczamy poprawne zaokrąglenie
			poprawna_odpowiedz = snapped(round(liczba * 10) / 10.0, 0.1)
		
		4: # do części setnych
			# Generujemy liczbę z 3 miejscami po przecinku
			var calosc = randi() % 100 + 1
			var ulamek = randi() % 999 + 1
			liczba = calosc + (ulamek / 1000.0)
			liczba = snapped(liczba, 0.001) # Zaokrąglamy do 3 miejsc po przecinku dla czytelności
			# Obliczamy poprawne zaokrąglenie
			poprawna_odpowiedz = snapped(round(liczba * 100) / 100.0, 0.01)
	
	# Formatujemy liczbę do wyświetlenia w pytaniu (zamieniamy kropkę na przecinek)
	var liczba_tekst = str(liczba).replace(".", ",")
	
	# Tworzymy pytanie
	var pytanie = "Zaokrąglij liczbę " + liczba_tekst + " " + typ_zaokraglania + "."
	
	# Generujemy błędne odpowiedzi
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	match indeks_typu:
		0, 1: # do setek lub do dziesiątek
			# Pierwsza błędna odpowiedź - zaokrąglenie w dół
			bledna_odpowiedz1 = poprawna_odpowiedz - (100 if indeks_typu == 0 else 10)
			# Druga błędna odpowiedź - zaokrąglenie w górę
			bledna_odpowiedz2 = poprawna_odpowiedz + (100 if indeks_typu == 0 else 10)
			
			# Jeśli zaokrąglenie w dół jest już poprawne, zmieniamy błędną odpowiedź
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + 50 if indeks_typu == 0 else poprawna_odpowiedz + 5
			
			# Jeśli zaokrąglenie w górę jest już poprawne, zmieniamy błędną odpowiedź
			if bledna_odpowiedz2 == poprawna_odpowiedz:
				bledna_odpowiedz2 = poprawna_odpowiedz - 50 if indeks_typu == 0 else poprawna_odpowiedz - 5
		
		2: # do jedności (całości)
			# Typowe błędy: zaokrąglenie w złą stronę lub obcięcie części ułamkowej
			bledna_odpowiedz1 = floor(liczba) # Obcięcie części ułamkowej
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + 1
			
			bledna_odpowiedz2 = ceil(liczba) # Zaokrąglenie w górę
			if bledna_odpowiedz2 == poprawna_odpowiedz:
				bledna_odpowiedz2 = poprawna_odpowiedz - 1
		
		3, 4: # do części dziesiętnych lub setnych
			# Typowe błędy: zaokrąglenie w złą stronę lub o jedno miejsce za mało/dużo
			var blad_kierunku = 0.1 if indeks_typu == 3 else 0.01
			
			# Pierwsza błędna odpowiedź - zaokrąglenie w dół lub o jedno miejsce za dużo
			if randi() % 2 == 0:
				bledna_odpowiedz1 = snapped(floor(liczba * (10 if indeks_typu == 3 else 100)) / (10.0 if indeks_typu == 3 else 100.0), blad_kierunku)
			else:
				bledna_odpowiedz1 = snapped(round(liczba * (100 if indeks_typu == 3 else 1000)) / (100.0 if indeks_typu == 3 else 1000.0), blad_kierunku / 10)
			
			# Upewniamy się, że odpowiedź jest błędna
			if bledna_odpowiedz1 == poprawna_odpowiedz:
				bledna_odpowiedz1 = poprawna_odpowiedz + blad_kierunku
			
			# Druga błędna odpowiedź - zaokrąglenie w górę lub o jedno miejsce za mało
			if randi() % 2 == 0:
				bledna_odpowiedz2 = snapped(ceil(liczba * (10 if indeks_typu == 3 else 100)) / (10.0 if indeks_typu == 3 else 100.0), blad_kierunku)
			else:
				bledna_odpowiedz2 = snapped(round(liczba * (1 if indeks_typu == 3 else 10)) / (1.0 if indeks_typu == 3 else 10.0), blad_kierunku * 10)
			
			# Upewniamy się, że odpowiedź jest błędna i różna od pierwszej błędnej
			if bledna_odpowiedz2 == poprawna_odpowiedz or bledna_odpowiedz2 == bledna_odpowiedz1:
				bledna_odpowiedz2 = poprawna_odpowiedz - blad_kierunku
	
	# Formatujemy odpowiedzi z części ułamkowej (zamieniamy kropkę na przecinek)
	if indeks_typu == 3 or indeks_typu == 4:
		poprawna_odpowiedz = str(poprawna_odpowiedz).replace(".", ",")
		bledna_odpowiedz1 = str(bledna_odpowiedz1).replace(".", ",")
		bledna_odpowiedz2 = str(bledna_odpowiedz2).replace(".", ",")
	else:
		# Konwertujemy na string dla porównania
		poprawna_odpowiedz = str(poprawna_odpowiedz)
		bledna_odpowiedz1 = str(bledna_odpowiedz1)
		bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	# Ostateczne sprawdzenie, czy obie błędne odpowiedzi różnią się od siebie
	if bledna_odpowiedz1 == bledna_odpowiedz2:
		# Jeśli odpowiedzi są takie same, modyfikujemy jedną z nich
		if indeks_typu <= 1:  # dla setek lub dziesiątek
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz2 = str(int(bledna_odpowiedz2) + mnoznik * 2)
		elif indeks_typu == 2:  # dla jedności
			bledna_odpowiedz2 = str(int(bledna_odpowiedz2) + 2)
		else:  # dla części dziesiętnych lub setnych
			var wartosc = float(bledna_odpowiedz2.replace(",", "."))
			var nowa_wartosc = wartosc + (0.2 if indeks_typu == 3 else 0.02)
			bledna_odpowiedz2 = str(nowa_wartosc).replace(".", ",")
	
	# Upewniamy się, że żadna z błędnych odpowiedzi nie jest równa poprawnej
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		if indeks_typu <= 1:  # dla setek lub dziesiątek
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz1 = str(int(poprawna_odpowiedz) + mnoznik)
		elif indeks_typu == 2:  # dla jedności
			bledna_odpowiedz1 = str(int(poprawna_odpowiedz) + 1)
		else:  # dla części dziesiętnych lub setnych
			var wartosc = float(poprawna_odpowiedz.replace(",", "."))
			var nowa_wartosc = wartosc + (0.1 if indeks_typu == 3 else 0.01)
			bledna_odpowiedz1 = str(nowa_wartosc).replace(".", ",")
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		if indeks_typu <= 1:  # dla setek lub dziesiątek
			var mnoznik = 100 if indeks_typu == 0 else 10
			bledna_odpowiedz2 = str(int(poprawna_odpowiedz) - mnoznik)
		elif indeks_typu == 2:  # dla jedności
			bledna_odpowiedz2 = str(int(poprawna_odpowiedz) - 1)
		else:  # dla części dziesiętnych lub setnych
			var wartosc = float(poprawna_odpowiedz.replace(",", "."))
			var nowa_wartosc = wartosc - (0.1 if indeks_typu == 3 else 0.01)
			bledna_odpowiedz2 = str(nowa_wartosc).replace(".", ",")
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]

# Funkcja pomocnicza do konwersji liczby na znaki Unicode dla wykładnika
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

# Funkcja generująca pytanie o potęgi z wykładnikiem naturalnym
func generuj_pytanie_potegi():
	# Określamy zakres podstawy i wykładnika
	var min_podstawa = -10
	var max_podstawa = 10
	var min_wykladnik = 2  # Startujemy od wykładnika 2, bo potęga pierwsza jest trywialna
	var max_wykladnik = 4  # Ograniczamy do 4, żeby wyniki nie były zbyt duże
	
	# Generujemy podstawę i wykładnik
	var podstawa = randi() % (max_podstawa - min_podstawa + 1) + min_podstawa
	var wykladnik = randi() % (max_wykladnik - min_wykladnik + 1) + min_wykladnik
	
	# Specjalne przypadki: unikamy 0⁰ (jest to wartość umowna 1, ale może być myląca)
	if podstawa == 0:
		podstawa = randi() % 10 + 1  # Losujemy liczbę od 1 do 10 zamiast 0
	
	# Obliczamy poprawną odpowiedź
	var poprawna_odpowiedz = pow(podstawa, wykladnik)
	
	# Konstruujemy pytanie
	var pytanie
	var wykladnik_unicode = liczba_na_wykladnik_unicode(wykladnik)
	
	# Szczególne przypadki formatowania
	if podstawa < 0:
		pytanie = "Ile wynosi (" + str(podstawa) + ")" + wykladnik_unicode + "?"
	else:
		pytanie = "Ile wynosi " + str(podstawa) + wykladnik_unicode + "?"
	
	# Generujemy błędne odpowiedzi
	var bledna_odpowiedz1
	var bledna_odpowiedz2
	
	# Typowe błędy przy potęgach:
	
	# 1. Mnożenie podstawy przez wykładnik zamiast potęgowania
	bledna_odpowiedz1 = podstawa * wykladnik
	
	# 2. Niewłaściwe zastosowanie reguł potęgowania dla liczb ujemnych
	# lub pomylenie znaku przy parzystym/nieparzystym wykładniku
	if podstawa < 0 and wykladnik % 2 == 0:
		# Dla ujemnej podstawy i parzystego wykładnika, typowy błąd to wynik ujemny
		bledna_odpowiedz2 = -poprawna_odpowiedz
	elif podstawa < 0 and wykladnik % 2 == 1:
		# Dla ujemnej podstawy i nieparzystego wykładnika, typowy błąd to wynik dodatni
		bledna_odpowiedz2 = -poprawna_odpowiedz
	else:
		# Inny typowy błąd: obliczenie potęgi o jeden mniejszej lub większej
		if randi() % 2 == 0:
			bledna_odpowiedz2 = pow(podstawa, wykladnik - 1)
		else:
			bledna_odpowiedz2 = pow(podstawa, wykladnik + 1)
	
	# Sprawdzamy, czy błędne odpowiedzi nie są takie same jak poprawna
	if bledna_odpowiedz1 == poprawna_odpowiedz:
		bledna_odpowiedz1 = poprawna_odpowiedz + (1 if poprawna_odpowiedz >= 0 else -1)
	
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz + (2 if poprawna_odpowiedz >= 0 else -2)
	
	# Sprawdzamy, czy błędne odpowiedzi nie są takie same
	if bledna_odpowiedz1 == bledna_odpowiedz2:
		bledna_odpowiedz2 = bledna_odpowiedz1 + (3 if bledna_odpowiedz1 >= 0 else -3)
	
	# Jeśli któraś z błędnych odpowiedzi po modyfikacji stałaby się równa poprawnej
	if bledna_odpowiedz2 == poprawna_odpowiedz:
		bledna_odpowiedz2 = poprawna_odpowiedz * 2
	
	# Konwertujemy odpowiedzi na stringi
	poprawna_odpowiedz = str(poprawna_odpowiedz)
	bledna_odpowiedz1 = str(bledna_odpowiedz1)
	bledna_odpowiedz2 = str(bledna_odpowiedz2)
	
	# Zwracanie pytania w formacie ['Question','GOOD','BAD','BAD']
	return [pytanie, poprawna_odpowiedz, bledna_odpowiedz1, bledna_odpowiedz2]
