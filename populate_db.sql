PROMPT Wypelnianie bazy danych...
SET FEEDBACK OFF
PROMPT Wypelnianie tabeli Rola...
insert into rola(nazwa) values ('ubezpieczaj¥cy');
insert into rola(nazwa) values ('ubezpieczony')	;
commit;

PROMPT Wypelnianie tabeli Szkody_Status...
insert into szkody_status values (1,'zgˆoszona');
insert into szkody_status values (2,'rozpatrywana');
insert into szkody_status values (3,'odrzucona');
insert into szkody_status values (4,'wypˆacona');
commit;


PROMPT Wypelnianie hurtowe tabeli Agenci(&&ilosc_agentow_hurt)...
exec agenci_pkg.dodaj_agenta_hurt(p_ilosc=>&&ilosc_agentow_hurt, p_nazwa_agenta=>'Agent nr',p_autonum=>TRUE);

PROMPT Wypelnianie hurtowe tabeli Polisy + Osoby + Kontrahenci(&&ilosc_polis_hurt polis)...
exec polisy_pkg.dodaj_polise_hurt (&&ilosc_polis_hurt, &&max_osob_na_polisie, &&data_polisy_od, &&data_polisy_do, &&skladka_proc, &&suma_min, &&suma_max, &&procent);

PROMPT Wypelnianie hurtowe tabeli Szkody(&&ilosc_szkod_hurt)...
exec ins.szkody_pkg.dodaj_szkode_hurt(&&ilosc_szkod_hurt,&&max_szkod_na_polisie);

exec dbms_mview.refresh('mv_polisy_koniec');
commit;
/