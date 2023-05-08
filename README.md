1. ZAŁOŻENIA 

Projekt został wykonany w środowisku Oracle Express Edition 21c
Tematem jest baza danych, która symuluje (w dużym uproszczeniu) działanie towarzystwa ubezpieczeniowego.
Możliwe jest dodawanie, usuwanie oraz modyfikacja polis, agentów oraz osób wraz z powiązanymi danymi z innych tabel.

Każda polisa jest powiązana z 1 agentem.
Każdy agent może wprowadzić wiele polis.
Do każdej polisy są przypisane osoby: jedna jako ubezpieczający oraz jedna lub wiele jako ubezpieczeni.
Z każdej polisy można zgłosić jedną lub wiele szkód.
Szkoda ma 4 możliwe statusy: zgłoszona (1), rozpatrywana (2), odrzucona (3), wypłacona (4).
Tylko dla statusu 4 kwota wypłaty może być większa od 0	- do zrobienia
Szkoda powinna być rozpatrzona w czasie 14 dni od zgłoszenia

Baza zapisuje w tabeli info_log informacje dotyczące logowania i wylogowania użytkowników (triggery LOGON, LOGOFF)
Baza zapisuje w tabeli info_dane informacje dotyczące pracy z danymi w tabelach agenci, polisy, szkody (trigger DML) - do zrobienia

Baza 1 raz dziennie uruchamia job  o nazwie „job_stat” który odświeża statystyki tabel faktów (tabele polisy, kontrahenci, szkody) 
oraz zapisuje dane o liczbie ich wierszy do tabeli stat_info.

Baza 1 raz dziennie odświeża widok zmaterializowany o nazwie „mv_polisy_koniec” który zawiera informacje nt. polis oraz ich właścicieli, dla polis których termin ważności upływa w ciągu 7 dni

Baza posiada możliwość indywidualnego oraz hurtowego dodawania danych (w celu uzyskania szybkiego przyrostu informacji w bazie) 
(funkcjonalność w trakcie tworzenia, na chwilę obecną można hurtowo dodać agentów)

Więcej informacji znajduje się w pliku Opis.docx



2. INSTALACJA

Instalacja bazy danych może odbyć się na 2 sposoby:
- poprzez uruchomienie w bazie danych skryptu z pliku 00_create.sql (należy ustawić w nim swoje parametry w sekcji USTAWIENIA BAZY, z tego pliku uruchamiane są kolejne skrypty) Instalacja na samym początku sprawdza czy istnieje podany schemat użytkownika w wybranej lokalizacji i jeśli tak to go usuwa po czym tworzy od nowa użytkownika i wszystkie potrzebne składniki.

- poprzez import pliku insurance_schema.dmp wygenerowanego przez expdp, zawierającego ostatnią wersję schematu INS z bazą danych ( w tym wypadku należy mieć już utworzony schemat użytkownika  z nadanymi odpowiednimi uprawnieniami)
 


Ustawienia językowe bazy danych to EE8PC852

Przykładowe screeny z DB:

Istalacja ze skryptu
![instalacja_sqlplus](https://user-images.githubusercontent.com/77076749/236795133-25262ae5-2e23-44fb-b363-30a90b5161f3.JPG)

Istalacja poprzez DataPump
![instalacja_imdp](https://user-images.githubusercontent.com/77076749/236795240-3b529a12-a91e-4b1c-9779-a5d9a2a79cf5.JPG)

Kod widoku Agenci_Wskazniki
![widok_agenci_wsk](https://user-images.githubusercontent.com/77076749/236795768-8b55aca5-d90a-44a6-9546-31d3426c2ca0.JPG)

Kod widoku V_Wskazniki_Szkodowosci
![widok_wsk_szkod](https://user-images.githubusercontent.com/77076749/236795793-580efbc4-75bf-4950-8684-cbb2a6f6256b.JPG)

Kod procedury Dodaj_Agentow_Hurt
![procedura_dodaj_agentow_hurt](https://user-images.githubusercontent.com/77076749/236802467-da0c0cb2-6345-4541-bb30-9304796c971a.JPG)

