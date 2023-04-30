========================================================================================================
ZAŁOŻENIA 
========================================================================================================

Projekt został wykonany w środowisku Oracle Express Edition 21c
Tematem jest baza danych, która symuluje (w dużym uproszczeniu) działanie towarzystwa ubezpieczeniowego.
Możliwe jest dodawanie, usuwanie oraz modyfikacja polis, agentów oraz osób wraz z powiązanymi danymi z innych tabel.

Każda polisa jest powiązana z 1 agentem oraz z osobami na polisie.
Każdy agent może wprowadzić wiele polis.
Do każdej polisy są przypisane osoby: jedna jako ubezpieczający oraz jedna lub wiele jako ubezpieczeni.
Z każdej polisy można zgłosić jedną lub wiele szkód.
Szkoda ma 4 możliwe statusy: zgłoszona, rozpatrywana, odrzucona, wypłacona.
Szkoda powinna być rozpatrzona w czasie 14 dni od zgłoszenia

Baza zapisuje w tabeli info_log informacje dotyczące logowania i wylogowania użytkowników (triggery LOGON, LOGOFF)
Baza zapisuje w tabeli info_dane informacje dotyczące pracy z danymi w tabelach agenci, polisy, szkody (trigger DML)
Baza 1 raz dziennie generuje widok zmaterializowany pokazujący
Baza 1 raz dziennie odświeża statystyki tabel 
Baza 1 raz dziennie eksportuje wszystkie swoje dane za pomocą job --> dbms.datapump

Tabele:
	osoby
	agenci
	polisy	(podzielona na partycje względem lat)
	kontrahenci
	szkody (podzielona na partycje względem lat)
	imiona_meskie					- baza imion
	imiona_zenskie					- baza imion
	nazwiska_meskie					- baza nazwisk
	nazwiska_zenskie					- baza nazwisk
info_log						- informacje na temat logowania / wylogowania

Relacje:
	agenci	polisy		1:M
	osoby	kontrahenci	1:M
	polisy	kontrahenci 	1:M
	polisy	szkody		1:M

Baza posiada możliwość indywidualnego oraz hurtowego (w celu szybkiego uzyskania dużej bazy danych) dodawania zdarzeń.

========================================================================================================
OPERACJE HURTOWE
========================================================================================================

Baza imion i nazwisk
Baza korzysta z tabel imion i nazwisk które powstały poprzez przeniesienie pierwszych 2000 wierszy z zewnętrznej bazy imion oraz nazwisk (pliki csv)
https://dane.gov.pl/pl/dataset/1681,nazwiska-osob-zyjacych-wystepujace-w-rejestrze-pesel
https://dane.gov.pl/pl/dataset/1501
Dane źródłowe są posortowane od najczęściej do najrzadziej występujących.

Najpierw tworzone są tabele zewnętrzne (external tables) aby uzyskać dostęp do danych z plików *.csv 
następnie na ich podstawie tworzone są właściwe tabele ograniczone do 2000 wierszy z najczęściej występującymi imionami i nazwiskami

Tabele
- imiona_meskie
- imiona_zenskie
- nazwiska_meskie
- nazwiska_zenskie

Hurtowe dodawanie agentów:
		
Pakiet agenci_pkg_dodaj_agentow_hurt(p_nazwa_agenta:=’Agent’, p_ilosc:=1, p_autonum:=TRUE)

Składa się z funkcji publicznych i prywatnych
Sprawdza max numer agenta w tabeli agenci i dodaje na kolejnych miejscach nowych agentów.
Domyślna nazwa to ‘Agent’
Domyślnie dodawana jest autonumeracja po nazwie 
Domyślne nazwy agentów z autonumeracją to 'Agent 00x' , gdzie 'x' = nr_agenta (generowany przez sekwencję identity)
	
Funkcje pakietu:
- dodaj agentow_hurt		(pub)	- dodaj podaną liczbę agentów do tabeli agenci
- dodaj agenta			(pub)	- dodaj podaną liczbę agentów do tabeli agenci
- ustaw_seq			(priv)	- ustawia seq na ostatni nr_agenta w tabeli agenci

	
Hurtowe dodawanie polis:

Pakiet polisy_pkg.dodaj_polisy_hurt (ilosc_polis, data min, data max, ilosc_osob) 

Składka jest liczona jako 10% sumy ubezpieczenia 
Ilość osób	- ile max osób może być dodanych na polisach (od 0 do ilosc_osob)

Dodanie polisy musi dodawać co najmniej 2 wpisy w tabeli kontrahenci (1 osoba która kupuje polisę jako ubezpieczający i 1 osoba jako ubezpieczony

Pakiet osoby_pkg.dodaj_osoby_hurt(ilosc osob) 
		
Dla każdej polisy generowana jest losowa ilość osób z podanego zakresu,może być więcej ubezpieczonych. 
Na tej podstawie generowane są osoby, które są dodawane do polisy jako ubezpieczony (tabela osoby i kontrahenci). 
				
Hurtowe dodawanie szkód:

Pakiet szkody_pkg.dodaj_szkody(ilosc,max_ilosc_szkod)

Z tabeli polisy losowane są numery polis na których zostanie zgłoszona szkoda oraz jej status
Dla każdej wylosowanej polisy zostaną wygenerowana od 1 do n ilość szkód (n=max_ilość_szkód)
Tylko dla szkód ze statusem zatwierdzona zostanie wpisana wyplata w losowej kwocie z zakresu od 0 do suma_ubezpieczenia

========================================================================================================
OPERACJE DETALICZNE
========================================================================================================

Dodawanie agenta:

Pakiet agenci_pkg.dodaj_agenta(p_nazwa_agenta,p_autonum:=FALSE)

1)	dodaje 1 agenta o wybranej nazwie wywołując wewnątrz procedurę dodaj_agentow_hurt
2)	Domyślnie nie dodaje autonumeracji po nazwie



Dodawanie polisy:

Pakiet polisy_pkg.dodaj_polise
Pakiet osoby_pkg.dodaj_osobe (obsługuje wpisy do 2 tabel- osoby + kontrahenci)

1) dodać polisę 
2) dodać do polisy osoby wraz z ich rolą na polisie (tabela osoba + kontrahenci)


Dodawanie szkody:

Pakiet szkody_pkg.dodaj_szkode

1) dodać szkodę do wybranej polisy

========================================================================================================
FUNKCJONALNOŚCI BAZY
========================================================================================================

Generowanie widoków
1) kwoty wypłaconych odszkodowań w podziale na m-ce wg daty zgłoszenia w wybranym zakresie czasu
2) średni czas (w dniach) jaki upłynął od zajścia szkody do jej zgłoszenia w wybranym kwartale które zakończyły się wypłatą.
3) suma wpłaconych składek do sumy wypłaconych odszkodowań w podziale na m-ce w wybranym roku


Widoki
1) dane osób + liczba powiązanych polis, gdzie osoby występują jako 'ubezpieczaajacy'
2) numery polis dla których ubezpieczający i ubezpieczany to ta sama osoba
3) wszyscy agenci (również ci bez polis) wraz z ilością sprzedanych polis oraz wskaźnikiem, ile tych polis jest aktywnych na dzisiaj
4) szkody, które zaszły w okresie ubezpieczenia a zostały zgłoszone po zakończeniu okresu ubezpieczenia
5) liczba szkód oraz wartość wypłaconych odszkodowań pogrupowanych według peseli osób, które zawarły ubezpieczenia (występują w roli ubezpieczający) Na zestawieniu wykazać tylko te pozycje, dla których łączna wartość wypłat przekracza 100 tys.
6) polisy, do których zostały zgłoszone szkody i dla których wartość wypłaty przekracza sumę ubezpieczenia.
7) polisy, do których nie została zgłoszona szkoda.
8) przeterminowane szkody – szkody, które zostały zgłoszone a nie zostały rozpatrzone w czasie 14 dni
9) stosunek (wyrażony w %) liczby polis ze szkodami do łącznej liczby polis oraz stosunek (wyrażony w %) łącznej kwoty wypłaty odszkodowania do łącznej sumy ubezpieczenia z polis, do których została zgłoszona co najmniej jedna szkoda.
10) ilość wpłaconych składek do ilości wypłaconych odszkodowań w podziale na lata

============
wprowadz polise i pobierz jej numer (ostatni numer polis)
wprowadz dane osobowe osob na polisie wraz z ich i okresl ich rolą
wpisz odpowiednie dane do tabeli kontrahenci

