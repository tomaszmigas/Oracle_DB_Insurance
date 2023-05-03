PROMPT Wypelnianie bazy danych danymi...
SET FEEDBACK OFF
PROMPT Wypelnianie tabeli Rola(2)...
insert into rola(nazwa) values ('ubezpieczajacy');
insert into rola(nazwa) values ('ubezpieczony')	;
commit;
PROMPT Gotowe

PROMPT Wypelnianie tabeli Agenci(&&ilosc_agentow_hurt)...
exec agenci_pkg.dodaj_agentow_hurt(p_nazwa_agenta=>'Agent',p_ilosc=>&&ilosc_agentow_hurt,p_autonum=>TRUE);
/
PROMPT Gotowe

PROMPT Wypelnianie tabeli Osoby(10)...
insert into osoby (imie,nazwisko,pesel) values ('Adam', 'Baran',	'80012801002');
insert into osoby (imie,nazwisko,pesel) values ('Piotr', 'Kulik',	'72112801003');
insert into osoby (imie,nazwisko,pesel) values ('Zofia', 'Kulik',	'75102101010');
insert into osoby (imie,nazwisko,pesel) values ('Paulina', 'Kulik',	'96017801208');
insert into osoby (imie,nazwisko,pesel) values ('Bartˆomiej', 'Kulik',	'98082801103');

insert into osoby (imie,nazwisko,pesel) values ('Anna', 'Hetmaäska','95041301004');
insert into osoby (imie,nazwisko,pesel) values ('Aneta', 'St©pna','00051801005');
insert into osoby (imie,nazwisko,pesel) values ('Maria', '½elazna-Wilk','85112001006');
insert into osoby (imie,nazwisko,pesel) values ('Kamil', 'Parnik','75081701007');
insert into osoby (imie,nazwisko,pesel) values ('Kamil', 'Karczewnik','97022101004');
/
PROMPT Gotowe

PROMPT Wypelnianie tabeli Polisy(3)...
exec polisy_pkg.wprowadz_polise(1,DATE '2023-01-01',DATE '2023-12-31' ,500,50000);
exec polisy_pkg.wprowadz_polise(1,DATE '2023-02-19',DATE '2024-02-18' ,300,30000);
exec polisy_pkg.wprowadz_polise(1,DATE '2022-03-20',DATE '2023-03-19' ,700,70000);
/
PROMPT Gotowe

PROMPT Wypelnianie tabeli Kontrahenci(2)...
insert into kontrahenci values (1,2,1);
insert into kontrahenci values (1,2,2);
commit;
/
PROMPT Gotowe
SET FEEDBACK On
