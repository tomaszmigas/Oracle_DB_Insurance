PROMPT Wypelnianie bazy danych...
SET FEEDBACK OFF
PROMPT Wypelnianie tabeli Rola(2)...
insert into rola(nazwa) values ('ubezpieczaj¥cy');
insert into rola(nazwa) values ('ubezpieczony')	;
commit;

PROMPT Wypelnianie tabeli Agenci(&&ilosc_agentow_hurt)...
exec agenci_pkg.dodaj_agentow_hurt(p_nazwa_agenta=>'Agent',p_ilosc=>&&ilosc_agentow_hurt,p_autonum=>TRUE);
/
commit;

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
insert into osoby (imie,nazwisko,pesel) values ('Anna', 'Karczewnik','98022101004');
commit;
/

PROMPT Wypelnianie tabeli Polisy(11)...
--p_nr_agenta, p_data_od date,  p_data_do date, p_suma_ubezpieczenia
--begin
exec polisy_pkg.dodaj_polise(1,DATE '2023-01-01',DATE '2023-12-31' ,50000);
exec polisy_pkg.dodaj_polise(2,DATE '2023-02-19',DATE '2024-02-18' ,30000);
exec polisy_pkg.dodaj_polise(3,DATE '2022-03-20',DATE '2023-03-19' ,70000);
exec polisy_pkg.dodaj_polise(4,DATE '2023-05-05',DATE '2024-05-04' ,10000);
exec polisy_pkg.dodaj_polise(5,DATE '2023-05-05',DATE '2024-05-04' ,20000);
exec polisy_pkg.dodaj_polise(6,DATE '2023-04-10',DATE '2024-04-09' ,45000);
exec polisy_pkg.dodaj_polise(6,DATE '2023-04-11',DATE '2024-04-10' , 5000);
exec polisy_pkg.dodaj_polise(5,DATE '2023-03-20',DATE '2024-03-19' , 4000);
exec polisy_pkg.dodaj_polise(5,DATE '2022-03-20',DATE '2023-03-19' , 3000);
exec polisy_pkg.dodaj_polise(2,DATE '2023-03-22',DATE '2024-03-21' , 25000);
exec polisy_pkg.dodaj_polise(2,DATE '2022-05-09',DATE '2023-05-08' , 17000);
--end;
/
--commit;

PROMPT Wypelnianie tabeli Kontrahenci(24)...
-- nr polisy, id_osoby,rola(1-ubezpieczaj¥cy 2-ubezpieczony
insert into kontrahenci values (1,2,1);
insert into kontrahenci values (1,2,2);

insert into kontrahenci values (2,10,1);
insert into kontrahenci values (2,10,2);
insert into kontrahenci values (2,11,2);

insert into kontrahenci values (3,3,1);
insert into kontrahenci values (3,3,2);
insert into kontrahenci values (3,4,2);
insert into kontrahenci values (3,5,2);
insert into kontrahenci values (3,6,2);

insert into kontrahenci values (4,2,1);
insert into kontrahenci values (4,2,2);

insert into kontrahenci values (5,2,1);
insert into kontrahenci values (5,2,2);

insert into kontrahenci values (6,10,1);
insert into kontrahenci values (6,10,2);

insert into kontrahenci values (7,2,1); 
insert into kontrahenci values (7,4,2); 

insert into kontrahenci values (8,2,1); 
insert into kontrahenci values (8,5,2); 

insert into kontrahenci values (9,2,1); 
insert into kontrahenci values (9,6,2); 

insert into kontrahenci values (10,4,1);
insert into kontrahenci values (10,6,2);

insert into kontrahenci values (11,6,1);
insert into kontrahenci values (11,6,2);

commit;
/

PROMPT Wypelnianie tabeli Szkody_Status(4)...
insert into szkody_status values (1,'zgˆoszona');
insert into szkody_status values (2,'rozpatrywana');
insert into szkody_status values (3,'odrzucona');
insert into szkody_status values (4,'wypˆacona');
commit;
/

PROMPT Wypelnianie tabeli Szkody(10)...
declare
	ex1 exception;
	pragma exception_init(ex1,-205998);
begin
--	nr_polisy, data_zdarzenia, data_zgloszenia, status (1-zgloszona	2-rozpatrywana 3-odrzucona 4-wypˆacona) , wyplata
	insert into szkody values (1,DATE'2023-03-12',DATE'2023-03-15',1,0);
	insert into szkody values (1,DATE'2023-04-16',DATE'2023-04-20',4,12000);
	insert into szkody values (1,DATE'2023-06-17',DATE'2023-07-05',4,37000);
	insert into szkody values (1,DATE'2023-08-17',DATE'2024-01-05',4,5000);

	insert into szkody values (2,DATE'2023-06-12',DATE'2023-06-20',1,0);
	insert into szkody values (2,DATE'2023-02-21',DATE'2023-02-21',3,0);

	insert into szkody values (3,DATE'2023-03-15',DATE'2023-03-16',4,80000);
	insert into szkody values (3,DATE'2023-02-21',DATE'2023-04-21',2,0);
	insert into szkody values (3,DATE'2023-01-17',DATE'2023-02-16',4,20000);
	insert into szkody values (3,DATE'2023-04-28',DATE'2023-04-29',3,0);
	
	insert into szkody values (10,DATE'2023-02-11',DATE'2023-02-12',4,7000);
	insert into szkody values (10,DATE'2023-04-15',DATE'2023-04-28',4,12000);

commit;
exception
	when others then
		dbms_output.put_line( 'Wyj¥tek ' || sqlcode ||  ' --> ' || sqlerrm);
	
end;
/

exec dbms_mview.refresh('mv_polisy_koniec');
/