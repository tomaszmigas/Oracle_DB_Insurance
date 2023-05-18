1. ZAŁOŻENIA 

Projekt został wykonany w środowisku Oracle Express Edition 21c
Tematem jest baza danych, która symuluje w uproszczeniu działanie towarzystwa ubezpieczeniowego.
Możliwe jest dodawanie, usuwanie oraz modyfikacja agentów, polis, osób oraz szkód wraz z powiązanymi danymi z innych tabel.

Każda polisa jest powiązana z 1 agentem.
Każdy agent może wprowadzić wiele polis.
Do każdej polisy są przypisane osoby: jedna jako ubezpieczający oraz jedna lub wiele jako ubezpieczeni.
Osoba ubezpieczająca może (ale nie musi) występować też jako osoba ubezpieczona na tej samej polisie.
Z każdej polisy można zgłosić jedną lub wiele szkód.
Szkoda ma 4 możliwe statusy: zgłoszona (1), rozpatrywana (2), odrzucona (3), wypłacona (4).
Tylko dla statusu 4 kwota wypłaty może być większa od 0
Szkoda do 5 dni od zgłoszenia widnieje jako "zgłoszona"
Po 5 dniach widnieje jako "rozpatrywana" i powinna być rozpatrzona w czasie do 14 dni od zgłoszenia.
Po 14 dniach szkoda powinna mieć 1 z 2 statusów "odrzucona" lub "wypłacona".

Baza zapisuje w tabeli info_log informacje dotyczące logowania i wylogowania użytkowników (triggery LOGON, LOGOFF)
Baza zapisuje w tabeli info_dane informacje dotyczące pracy z danymi w tabelach agenci, polisy, szkody (trigger DML) - do zrobienia
Baza 1 raz dziennie uruchamia job o nazwie „job_stat” który odświeża statystyki tabel faktów (tabele polisy, kontrahenci, szkody) 
oraz zapisuje dane o liczbie ich wierszy do tabeli stat_info.
Baza 1 raz dziennie odświeża widok zmaterializowany o nazwie „mv_polisy_koniec” który zawiera informacje nt. polis oraz ich właścicieli, dla polis których termin ważności upływa w ciągu 7 dni

W celu uzyskania szybkiego przyrostu ilości danych w bazie, posiada ona możliwość hurtowego dodawania agentów, polis oraz szkód.
Służą do tego procedury:

    ins.agenci_pkg.dodaj_agenta_hurt(ilosc,nazwa_agenta,autonum)
    
    ins.polisy_pkg.dodaj_polise_hurt(ilosc_polis,max_osob_na_1_polisie, data_min, data_max,skladka_proc,suma_min,suma_max,proc_uu)
         polisy zostaną losowo przydzielone do agentów którzy już istnieją w bazie
         proc_uu - prawdopodobienstwo w % że ubezpieczający na polisie będzie też występował na niej jako ubezpieczony
    
    ins.szkody_pkg.dodaj_szkode_hurt(ilos_szkod,max_szkod_na_1_polisie);
         szkody zostaną losowo wygenerowane dla polis które już istnieją w bazie


Więcej informacji znajduje się w pliku Opis.docx


2. INSTALACJA

Instalacja bazy danych może odbyć się na 2 sposoby:

a) poprzez uruchomienie w bazie danych skryptu z pliku 00_create.sql (należy ustawić w nim swoje parametry w sekcji USTAWIENIA BAZY, z tego pliku uruchamiane są kolejne skrypty) Instalacja na samym początku sprawdza czy istnieje podany schemat użytkownika w wybranej lokalizacji i jeśli tak to go usuwa po czym tworzy od nowa użytkownika i wszystkie potrzebne składniki.

b) poprzez import pliku insurance_schema.dmp wygenerowanego przez expdp, zawierającego ostatnią wersję schematu INS z bazą danych (w tym wypadku należy mieć już utworzony schemat użytkownika z nadanymi odpowiednimi uprawnieniami - przykładowy plik: user.sql)
 
Ustawienia językowe bazy danych to EE8PC852


3. Zagadnienia użyte w projekcie:

       DML,DDL,TCL
       Users, Tablespace, Quota
       Privileges: System Privileges, Object Privileges
       Subquery, JOIN, CTE (WITH)
       Table: Primary Key, Foreign Key, Constraint, Unique Index, Sequence (Identity), Partition By Range
       External Table
       View
       Materialized View (refresh on demand)
       DataPump: expdp, impdp
       Directory
       Procedure
       Function
       Trigger: DML, Logon, Logoff
       Index: B-Tree, Bitmap
       Statistics: Table Statistics
       Package (Spec + Body)
       Collection
       Job
       Exception
       IF-Else
       FOR - LOOP
       BULK COLLECT, FORALL
       Bind Variable, Substitution Variable
       Execute Immediate

Algorytm hurtowego dodawania polis: http://cacoo.com/diagrams/T1GwSGJwDbSqB0LG-E025A.png

Algorytm hurtowego dodawania szkód: http://cacoo.com/diagrams/T1GwSGJwDbSqB0LG-CDCF8.png



Przykładowe screeny z DB:


Schemat Bazy Danych
![schemat_bd](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/d4b64314-25e7-4da4-85c9-538256ab504d)


Instalacja ze skryptu

![instalacja_sqlplus](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/c907cccb-a3af-4f9e-a01c-868ec7e348b8)


Instalacja poprzez DataPump

![instalacja_imdp](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/2195def7-994a-4aef-9e2e-ab600f987caf)


Export poprzez DataPump (widoczny podział tabel na partycje)
![expdp](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/cdd928a2-3be6-4b66-8753-4dc325e49d03)


Kod i wynik działania widoku v_Wskazniki_Szkodowosci
![wsk_szkodowosci](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/493f7c3a-88c2-49bd-a31e-2bcabdf731a6)




Kod widoku Agenci_Wskazniki
![widok_agenci_wsk](https://user-images.githubusercontent.com/77076749/236795768-8b55aca5-d90a-44a6-9546-31d3426c2ca0.JPG)


Kod widoku V_Wskazniki_Szkodowosci
![widok_wsk_szkod](https://user-images.githubusercontent.com/77076749/236795793-580efbc4-75bf-4950-8684-cbb2a6f6256b.JPG)


Screen Dodaj_Agentow_Hurt
![procedura_dodaj_agentow_hurt](https://user-images.githubusercontent.com/77076749/236802467-da0c0cb2-6345-4541-bb30-9304796c971a.JPG)


Screen Dodaj_Szkody_Hurt
![procedura_dodaj_szkody_hurt](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/4c2d2240-9f6c-4fec-97ef-ea07d3b6aeb1)


Działanie Procedury dodaj_polisy_hurt
![procedura_dodaj_polisy_hurt](https://github.com/tomaszmigas/Oracle_DB_Insurance/assets/77076749/82963835-ba20-4d8e-88f0-6effb2ffa735)

