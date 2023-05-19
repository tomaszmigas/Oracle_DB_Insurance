--HOST chcp 1250
PROMPT Tworzenie widoków...

CREATE OR REPLACE VIEW v_polisy_osoby AS
SELECT imie, nazwisko, pesel, (SELECT COUNT(*) FROM kontrahenci k WHERE o.id_osoby = k.id_osoby AND id_roli =1) ilosc_polis 
FROM osoby o
;


CREATE OR REPLACE VIEW v_polisy_wlasciciele AS
WITH 
    k AS (SELECT count(nr_polisy) ilosc_polis, id_osoby FROM kontrahenci WHERE id_roli =1 GROUP BY id_osoby)
SELECT 
    imie, nazwisko, pesel, ilosc_polis FROM osoby o
INNER JOIN k USING(id_osoby)
;


CREATE OR REPLACE VIEW v_polisy_indywidualne_wlascicieli AS
SELECT nr_polisy from polisy p
INNER JOIN kontrahenci k1 using (nr_polisy)
INNER JOIN kontrahenci k2 using (nr_polisy)
INNER JOIN (SELECT count(*) ilosc, nr_polisy FROM kontrahenci k GROUP BY nr_polisy) k3 USING (nr_polisy)
WHERE k1.id_roli=1
AND k2.id_roli=1
AND k3.ilosc=2
;


CREATE OR REPLACE VIEW v_polisy_indywidualne AS
SELECT nr_polisy FROM
(SELECT count(*) ilosc, nr_polisy FROM kontrahenci k GROUP BY nr_polisy) k3 
WHERE 
k3.ilosc=2
;

CREATE OR REPLACE VIEW v_polisy_bez_szkod AS
select nr_polisy Polisy_bez_szkod from polisy 
minus 
select distinct nr_polisy from szkody;

CREATE OR REPLACE VIEW v_polisy_przekroczona_wartosc AS
SELECT nr_polisy, suma_ubezpieczenia, sum(wartosc_wyplaty) AS suma_wyplat, (sum(wartosc_wyplaty)- suma_ubezpieczenia) "PRZEKROCZENIE"  FROM szkody
INNER JOIN polisy USING (nr_polisy)
GROUP BY suma_ubezpieczenia, nr_polisy
HAVING SUM(wartosc_wyplaty) > suma_ubezpieczenia
;

create or replace view v_agenci_wskazniki AS
WITH
    wszystkie_polisy AS (SELECT count(nr_polisy) AS ilosc, nr_agenta FROM polisy GROUP BY nr_agenta)
    ,akt_polisy AS (SELECT count(nr_polisy) AS ilosc, nr_agenta FROM polisy WHERE data_do>=current_date GROUP BY nr_agenta)
SELECT nr_agenta, nazwa, NVL(wszystkie_polisy.ilosc,0) polisy
,to_char(NVL(round(akt_polisy.ilosc/wszystkie_polisy.ilosc*100,1),0),'990.99') || '%' AS wsk_akt_polis FROM agenci
LEFT JOIN wszystkie_polisy using (nr_agenta)
LEFT JOIN akt_polisy using  (nr_agenta)
;

CREATE OR REPLACE VIEW v_szkody_przeterminowane AS
SELECT nr_polisy,data_do "WA¯NOSC_POLISY", data_zgloszenia, trunc(data_zgloszenia-data_do) dni_przekroczenia FROM szkody
INNER JOIN polisy USING (nr_polisy)
WHERE data_zgloszenia>data_do
;



CREATE OR REPLACE VIEW v_szkody_opoznione AS
select  nr_polisy,data_zgloszenia,nazwa , trunc(current_date - data_zgloszenia) dni
from szkody
inner join szkody_status using (id_status)
where nazwa NOT IN ('wyp³acona','odrzucona')
AND (current_date - data_zgloszenia) >14
;


CREATE OR REPLACE VIEW v_szkody_wysokie AS
select count(*) liczba_szkod, sum(wartosc_wyplaty) suma, pesel from szkody
inner join polisy p using(nr_polisy)
inner join kontrahenci k using (nr_polisy)
inner join osoby o on (o.id_osoby = k.id_osoby)
inner join rola r using (id_roli)
where r.nazwa = 'ubezpieczaj¹cy'
group by pesel
having sum(wartosc_wyplaty)>20000
;


CREATE OR REPLACE VIEW V_WSKAZNIKI_SZKODOWOSCI AS
WITH
     p1 AS (select count(distinct nr_polisy) ilosc from szkody)
    ,p2 AS (select count(distinct nr_polisy) ilosc from polisy)
    ,p3 AS (select count(id_szkody) ilosc from szkody)
    ,w1 AS (select sum(wartosc_wyplaty) suma from szkody)
    ,w2 AS (select sum(skladka) suma from polisy p where exists (SELECT 1 FROM szkody s WHERE p.nr_polisy = s.nr_polisy))
    ,w3 AS (select sum(skladka) suma from polisy p)
SELECT 
 to_char(p2.ilosc,'999,999,990') "ILOŒÆ POLIS"
,to_char(p3.ilosc,'999,999,990') "ILOŒÆ SZKÓD"
,to_char(round((p1.ilosc/p2.ilosc)*100,2),'990.99')|| '%' "% POLIS ZE SZK"
,to_char(w1.suma,'999,999,999') "WYP£ACONE ODSZK"
,to_char(w2.suma,'999,999,999') "SKL POLIS ZE SZK"
,to_char(w3.suma,'999,999,999') "SKL WSZYST POLIS"
,round((w1.suma/w2.suma)*100,2) || '%' "ODSZK/SK£ADKI_SZK"
,round((w1.suma/w3.suma)*100,2) || '%' "ODSZK/SK£ADKI"
,to_char(w2.suma - w1.suma,'999,999,999') "BILANS POLIS SZK"
,to_char(w3.suma - w1.suma,'999,999,999') "BILANS CA£OŒÆ"
FROM p1,p2,P3,w1,w2,w3;
--koniec 