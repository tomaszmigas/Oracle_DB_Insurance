---------- usuwanie tabel imion i nazwisk ---------------------
drop table imiona_meskie;
drop table nazwiska_meskie;
drop table imiona_zenskie;
drop table nazwiska_zenskie;

---------- usuwanie pakietow ---------------------
PROMPT laczenie jako system ...
connect system/sys1@localhost:1521/xepdb3

drop package body ins.agenci_pkg;
drop package ins.agenci_pkg;

-- usuwanie tabel
drop table ins.kontrahenci;
drop table ins.szkody;
drop table ins.polisy;
drop table ins.osoby;
drop table ins.agenci;

----------------- usuwanie uzytkownika -----------------
-- drop user ins;

