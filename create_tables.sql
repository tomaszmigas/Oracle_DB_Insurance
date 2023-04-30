prompt Tworzenie tabeli Osoby...
create table osoby(
 id_osoby number generated always as identity
,imie varchar2(100) not null
,nazwisko varchar2(100) not null
,pesel varchar2(11)
,constraint osoby_pk PRIMARY KEY (id_osoby)
,constraint pesel_check CHECK(length(pesel)=11)
);

prompt Tworzenie tabeli Agenci...
create table agenci(
 nr_agenta number generated always as identity
,nazwa varchar2(100) not null
,constraint agenci_pk PRIMARY KEY (nr_agenta)
);

prompt Tworzenie tabeli Polisy...
create table polisy(
 nr_polisy number generated always as identity
,nr_agenta number not null
,data_od date	not null
,data_do date	not null
,skladka number	not null
,suma_ubezpieczenia number not null
,constraint polisy_pk PRIMARY KEY (nr_polisy)
,constraint agenci_polisy_fk FOREIGN KEY (nr_agenta) REFERENCES agenci (nr_agenta) ON DELETE CASCADE
)
partition by range (data_od) 
(
 partition do1990 values less than (DATE '1990-01-01')
,partition do2000 values less than (DATE '2000-01-01')
,partition do2010 values less than (DATE '2010-01-01')
,partition do2020 values less than (DATE '2020-01-01')
,partition reszta values less than (maxvalue)
);

prompt Tworzenie tabeli Szkody...
create table szkody(
 nr_polisy number not null
,data_zajscia date not null
,data_zgloszenia date not null
,status varchar2(50) not null 
,wartosc_wyplaty number default 0 not null
,constraint szkody_pk PRIMARY KEY (nr_polisy,data_zajscia)
,constraint szkody_polisy_fk FOREIGN KEY (nr_polisy) REFERENCES polisy (nr_polisy) ON DELETE CASCADE
,constraint szkody_status_chk CHECK (status IN ('zgloszona','rozpatrywana','odrzucona','wyplacona'))
,constraint szkody_daty_chk CHECK (data_zgloszenia>=data_zajscia)
)
partition by range (data_zajscia) 
(
 partition do1990 values less than (DATE '1990-01-01')
,partition do2000 values less than (DATE '2000-01-01')
,partition do2010 values less than (DATE '2010-01-01')
,partition do2020 values less than (DATE '2020-01-01')
,partition reszta values less than (maxvalue)
);

prompt Tworzenie tabeli Kontrahenci...
create table kontrahenci(
 nr_polisy number
,id_osoby number
,rola varchar2(50) not null
,constraint kontrahenci_pk PRIMARY KEY (nr_polisy,id_osoby,rola)
,constraint polisy_kontrah_fk FOREIGN KEY (nr_polisy) REFERENCES polisy (nr_polisy) ON DELETE CASCADE
,constraint osoby_kontrah_fk FOREIGN KEY (id_osoby) REFERENCES osoby (id_osoby) ON DELETE CASCADE
,constraint rola_chk CHECK (rola IN ('ubezpieczajacy','ubezpieczony') )
);

PROMPT Tworzenie tabeli info_log...
create table info_log (
 "ID"               number generated always as identity
,"EVENT"            varchar2(50)
,"DATA"             date not null
,"TIME"             varchar2(20)
,"USER"             varchar2(100) not null
,"DB_NAME"          varchar2(100) not null
,"SESSION_ID"       number	
,"IP_ADDRESS"       varchar2(100) not null
,"NETWORK_PROTOCOL" varchar2(100) not null
,constraint info_log_pk primary key ("ID")
);
