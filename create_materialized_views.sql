PROMPT Tworzenie widokow zmaterializowanych...

create materialized view mv_polisy_koniec
refresh force on demand
start with sysdate
next sysdate+1
AS 
SELECT nr_polisy, data_do, current_date, imie, nazwisko,trunc(data_do - current_date) dni
FROM polisy
INNER JOIN kontrahenci using(nr_polisy)
INNER JOIN osoby using (id_osoby)
INNER JOIN rola using(id_roli)
WHERE 
nazwa = 'ubezpieczaj�cy'
AND (data_do - current_date) between 0 and 7
order by dni desc
;