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

Baza posiada możliwość indywidualnego oraz hurtowego (w celu szybkiego uzyskania dużej ilości danych) dodawania zdarzeń. - hurt do zrobienia

Więcej informacji znajduje się w pliku Opis.docx



2. INSTALACJA

Głównym plikiem instalacyjnym jest plik 00_create_db.sql, który z kolei uruchamia pozostałe pliki.
W pliku tym w sekcji "ustawienia bazy" należy ustawić własne parametry.
Instalacja bazy danych odbywa się poprzez uruchomienie w bazie danych skryptu z pliku 00_create.sql
Instalacja na samym początku sprawdza czy istnieje już dany schemat użytkownika w wybranej lokalizacji (pdb) 
i jeśli tak usuwa go a następnie tworzy od nowa.
Ustawienia językowe bazy danych to EE8PC852