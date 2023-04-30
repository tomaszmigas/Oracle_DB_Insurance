--- imiona  meskie ----
PROMPT Tworzenie tabeli Imiona Meskie Ext...
create table imiona_meskie_ext (
 imie varchar2(50)
,liczba_wystapien number
)
organization external
(
TYPE ORACLE_LOADER
default directory ins_external_table
access parameters
    (
        records delimited by newline
        badfile 'imiona_meskie.bad'
        discardfile 'imiona_meskie.dsc'
        logfile 'imiona_meskie.log'
        skip 1
        fields terminated by ','
        (
        imie char(50) LRTRIM
        ,plec char(50)
        ,liczba_wystapien char(50)
        )
    )
    location ('imiona_meskie_2023.csv')
)
reject limit unlimited;

PROMPT Tworzenie tabeli Imiona Meskie...
create table imiona_meskie (
 id number generated always as identity
,imie varchar2(50)
,liczba_wystapien number
);

PROMPT Wypelnianie tabeli Imiona Meskie...
insert into imiona_meskie (imie,liczba_wystapien) select imie, liczba_wystapien from imiona_meskie_ext where rownum<=2000;
commit;

PROMPT Usuwanie tabeli Imiona Meskie Ext...
drop table imiona_meskie_ext;


-------------imiona zenskie -------------
prompt Tworzenie tabeli Imiona Zenskie Ext...
create table imiona_zenskie_ext (
 imie varchar2(50)
,liczba_wystapien number
)
organization external
(
TYPE ORACLE_LOADER
default directory ins_external_table
access parameters
    (
        records delimited by newline
        badfile 'imiona_zenskie.bad'
        discardfile 'imiona_zenskie.dsc'
        logfile 'imiona_zenskie.log'
        skip 1
        fields terminated by ','
        (
        imie char(50) LRTRIM
        ,plec char(50)
        ,liczba_wystapien char(50)
        )
    )
    location ('imiona_zenskie_2023.csv')
)
reject limit unlimited;

PROMPT Tworzenie tabeli Imiona Zenskie...
create table imiona_zenskie (
id number generated always as identity
,imie varchar2(50)
,liczba_wystapien number
);

PROMPT Wypelnianie tabeli Imiona Zenskie...
insert into imiona_zenskie(imie,liczba_wystapien) select imie,liczba_wystapien from imiona_zenskie_ext where rownum<=2000;
commit;

PROMPT Usuwanie tabeli Imiona Zenskie Ext...
drop table imiona_zenskie_ext;


-------------nazwiska meskie-------------

PROMPT Tworzenie tabeli Nazwiska Meskie Ext...
create table nazwiska_meskie_ext (
 nazwisko varchar2(50)
,liczba_wystapien number
)
organization external
(
TYPE ORACLE_LOADER
default directory ins_external_table
access parameters
    (
        records delimited by newline
        badfile 'nazwiska_meskie.bad'
        discardfile 'nazwiska_meskie.dsc'
        logfile 'nazwiska_meskie.log'
        skip 1
        fields terminated by ','
        (
        nazwisko char(50) LRTRIM
        ,liczba_wystapien char(50)
        )
    )
    location ('nazwiska_meskie_2023.csv')
)
reject limit unlimited;

PROMPT Tworzenie tabeli Nazwiska Meskie...
create table nazwiska_meskie (
 id number generated always as identity
,nazwisko varchar2(50)
,liczba_wystapien number
);

PROMPT Wypelnianie tabeli Nazwiska Meskie...
insert into nazwiska_meskie (nazwisko,liczba_wystapien) select nazwisko, liczba_wystapien from nazwiska_meskie_ext where rownum<=2000;
commit;

PROMPT Usuwanie tabeli Nazwiska Meskie Ext...
drop table nazwiska_meskie_ext;


-------------nazwiska zenskie -------------

PROMPT Tworzenie tabeli Nazwiska Zenskie Ext...
create table nazwiska_zenskie_ext (
 nazwisko varchar2(50)
,liczba_wystapien number
)
organization external
(
TYPE ORACLE_LOADER
default directory ins_external_table
access parameters
    (
        records delimited by newline
        badfile 'nazwiska_zenskie.bad'
        discardfile 'nazwiska_zenskie.dsc'
        logfile 'nazwiska_zenskie.log'
        skip 1
        fields terminated by ','
        (
        nazwisko char(50) LRTRIM
        ,liczba_wystapien char(50)
        )
    )
    location ('nazwiska_zenskie_2023.csv')
)
reject limit unlimited;

PROMPT Tworzenie tabeli Nazwiska Zenskie...
create table nazwiska_zenskie (
 id number generated always as identity
,nazwisko varchar2(50)
,liczba_wystapien number
);

PROMPT Wypelnianie tabeli Nazwiska Zenskie...
insert into nazwiska_zenskie (nazwisko,liczba_wystapien) select nazwisko, liczba_wystapien from nazwiska_zenskie_ext where rownum<=2000;
commit;

PROMPT Usuwanie tabeli Nazwiska Zenskie Ext...
drop table nazwiska_zenskie_ext;

---------------

