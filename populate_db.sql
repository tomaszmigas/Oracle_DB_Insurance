PROMPT Wypelnianie bazy danych danymi...
PROMPT Tworzenie Agentow...(&&ilosc_agentow_hurt)...
exec agenci_pkg.dodaj_agentow_hurt(p_nazwa_agenta=>'Agent',p_ilosc=>&&ilosc_agentow_hurt,p_autonum=>TRUE);
commit;
/




insert into osoby (imie,nazwisko,pesel) values ('Adam', 'Baran',	'80012801002');
insert into osoby (imie,nazwisko,pesel) values ('Piotr', 'Kulik',	'72112801003');
insert into osoby (imie,nazwisko,pesel) values ('Zofia', 'Kulik',	'75102101010');
insert into osoby (imie,nazwisko,pesel) values ('Paulina', 'Kulik',	'96017801208');
insert into osoby (imie,nazwisko,pesel) values ('Bartłomiej', 'Kulik',	'98082801103');

insert into osoby (imie,nazwisko,pesel) values ('Anna', 'Hetmańska','95041301004');
insert into osoby (imie,nazwisko,pesel) values ('Aneta', 'Stępna','00051801005');
insert into osoby (imie,nazwisko,pesel) values ('Maria', 'Żelazna-Wilk','85112001006');
insert into osoby (imie,nazwisko,pesel) values ('Kamil', 'Parnik','75081701007');

exec polisy_pkg.wprowadz_polise(1,DATE '2023-01-01',DATE '2023-12-31' ,500,50000);
exec polisy_pkg.wprowadz_polise(2,DATE '2023-02-19',DATE '2024-02-18' ,300,30000);
exec polisy_pkg.wprowadz_polise(3,DATE '2022-03-20',DATE '2023-03-19' ,700,70000);

/*
insert into kontrahenci (1,2,'ubezpieczajacy');
insert into kontrahenci (1,,'ubezpieczajacy');

*/
PROMPT Dane wprowadzone do DB