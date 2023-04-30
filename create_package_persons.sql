PROMPT Tworzenie pakietu Osoby(spec)...
create or replace PACKAGE OSOBY_PKG AS 
    procedure dodaj_osobe(p_imie varchar2,p_nazwisko varchar2,p_pesel char);
END OSOBY_PKG;
/

PROMPT Tworzenie pakietu Osoby(body)...
create or replace PACKAGE BODY OSOBY_PKG AS
-----------------
    procedure ustaw_seq IS
        v_max_osoba number;
    BEGIN
        select max(id_osoby) into v_max_osoba from osoby;  -- p_max_agent = max nr wiersza w tabeli agenci
                          
        if v_max_osoba >0 then --jezeli istnieja wiersze w tabeli osoby to ustaw sekwencje na kolejny wiersz (nawet jak jest już ustawiona ok)
                execute immediate 'alter table osoby 
                modify (id_osoby number GENERATED ALWAYS AS IDENTITY MINVALUE  1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1
                START WITH ' || (v_max_osoba +1) || ' CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE)';
        else --gdy p_max_agent IS NULL --> tabela jest pusta to ustaw sekwencje na 1
                execute immediate 'alter table osoby 
                modify (id_osoby number GENERATED ALWAYS AS IDENTITY MINVALUE  1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1
                START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE)';
                v_max_osoba:=0;
        end if;
    END;
-----------------
    procedure dodaj_osobe(p_imie varchar2,p_nazwisko varchar2,p_pesel char) AS
        BEGIN
            ustaw_seq;
            INSERT INTO osoby(imie,nazwisko,pesel) VALUES (p_imie,p_nazwisko,p_pesel);
            dbms_output.put_line('Osoba dodana');
        END dodaj_osobe;
   
-----------------

END OSOBY_PKG;
/