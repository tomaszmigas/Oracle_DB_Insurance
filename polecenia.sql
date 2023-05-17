set serveroutput on;

-- dodawanie agentow----------
exec ins.agenci_pkg.dodaj_agenta_hurt(p_ilosc=>50,p_nazwa_agenta =>' Towarzystwo',p_autonum=>true);

-- dodawanie polis------------
-- 1=ilosc polis 2=max ilosc osob na polisie 3=data poczatkowa polis 4=data koncowa polis 5=min suma ubezp 6=max suma ubezp 7=szansa ze ubezepiczajacy bedzie tez ubezpieczonym na tej samej polisie
exec ins.polisy_pkg.dodaj_polise_hurt (500,5, DATE'1970-01-01', to_date(current_date),20,4000, 100000,40);

-- dodawanie szkod------------
-- 1=ilosc szkod, 2=max ilosc szkod na 1 polisie
exec ins.szkody_pkg.dodaj_szkode_ilosc_hurt(10,5);

select * from ins.v_agenci_wskazniki;
select * from V_POLISY_BEZ_SZKOD;
select * from V_POLISY_INDYWIDUALNE;
select * from V_POLISY_INDYWIDUALNE_WLASCICIELI;
select * from V_POLISY_OSOBY order by ilosc_polis desc;
select * from V_POLISY_PRZEKROCZONA_WARTOSC;
select * from V_POLISY_WLASCICIELE;
select * from V_SZKODY_OPOZNIONE;
select * from V_SZKODY_PRZETERMINOWANE;
select * from V_SZKODY_WYSOKIE;
select * from V_WSKAZNIKI_SZKODOWOSCI;
select * from mv_polisy_koniec;


SELECT * FROM SZKODY_STATUS;
-- ilosci szkod pogrupowane wgledem statusu szkody ==> 2 spoosby
select count(*), id_status from ins.szkody group by id_status order by id_status;
select distinct id_status,count(id_szkody) over(partition by id_status) ilosc_polis from ins.szkody;

select ins.p.data_od,ins.p.data_do,ins.s.data_zajscia, ins.s.data_zgloszenia, ins.s.id_status,
p.data_do - s.data_zajscia "Dni Do Konca", to_date(current_date) - s.data_zgloszenia czas_od_zglosz
from ins.szkody s 
inner join ins.polisy p using (nr_polisy)
where 
ins.s.data_zajscia <ins.p.data_do
--and id_status =2
and ins.s.data_zgloszenia <= ins.p.data_do
AND current_date - ins.s.data_zgloszenia <=25
order by data_zajscia desc
;

select p.data_od, p.data_do, s.data_zajscia, s.data_zgloszenia, id_status id, ss.nazwa,s.wartosc_wyplaty from ins.polisy p
inner join ins.szkody s using (nr_polisy)
inner join ins.szkody_status ss using (id_status)
order by data_zgloszenia desc;