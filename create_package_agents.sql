PROMPT Tworzenie pakietu Agenci (spec)..
create or replace package agenci_pkg is
    function wylosuj_agenta return  number;
    procedure dodaj_agenta(p_nazwa_agenta varchar2,p_autonum BOOLEAN:=FALSE);
    procedure dodaj_agenta_hurt(p_ilosc number:=1,p_nazwa_agenta varchar2 default 'Agent',p_autonum BOOLEAN:=TRUE);
    
end;
/

PROMPT Tworzenie pakietu Agenci (body)..
create or replace package body agenci_pkg is

--------------------------------------------------------------------    
     procedure ustaw_seq(p_max_agent OUT number) IS
    BEGIN
        select max(nr_agenta) into p_max_agent from agenci;  -- p_max_agent = max nr wiersza w tabeli agenci
                          
        if p_max_agent >0 then --jezeli istnieja wiersze w tabeli agenci to ustaw sekwencje na kolejny wiersz (nawet jak jest ju� ustawiona ok)
                execute immediate 'alter table agenci 
                modify (nr_agenta number GENERATED ALWAYS AS IDENTITY MINVALUE  1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1
                START WITH ' || (p_max_agent +1) || ' CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE)';
        else --gdy p_max_agent IS NULL --> tabela jest pusta to ustaw sekwencje na 1
                execute immediate 'alter table agenci 
                modify (nr_agenta number GENERATED ALWAYS AS IDENTITY MINVALUE  1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1
                START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE)';
                p_max_agent:=0;
        end if;
    END;
--------------------------------------------------------------------


--------------------------------------------------------------------
-- przy imporcie calego schematu tworzone sa od nowa obiekty w tym sekwencje, tabele moga juz zawierac dane
-- trzeba dopasowac wartosc startowa sekwencji do ilosci wierszy
    
    procedure dodaj_agenta_hurt(p_ilosc number:=1,p_nazwa_agenta varchar2 default 'Agent',p_autonum BOOLEAN:=TRUE) IS
        v_nazwa_agenta varchar2(100);
        v_max_agent number(10,0):=0;
    begin
        ustaw_seq(v_max_agent);     -- ustawia "start with" sekwencji na wartosc max_agenta

         for i in v_max_agent+1..v_max_agent+p_ilosc LOOP ---- start od kolejnego wiersza po max
            CASE p_autonum
		WHEN TRUE THEN v_nazwa_agenta:=p_nazwa_agenta || TO_CHAR(i,'000');
		WHEN FALSE THEN v_nazwa_agenta:=p_nazwa_agenta;
            END CASE;
            
            execute immediate 'INSERT INTO agenci (nazwa) VALUES (:1)' using v_nazwa_agenta;
        END LOOP;
        IF p_ilosc=1 THEN
            dbms_output.put_line('Utworzono ' || p_ilosc || ' agenta');
        ELSE 
            dbms_output.put_line('Utworzono ' || p_ilosc || ' agentow');
        END IF;
		COMMIT;
    exception
        when others then
            dbms_output.put_line('Agenci_pkg.Dodaj_agentow - wyjatek Others');
            dbms_output.put_line('SQLCode: ' || sqlcode || '   SQL Errm: ' || sqlerrm);
            rollback;
    
    end dodaj_agenta_hurt;
--------------------------------------------------------------------

--------------------------------------------------------------------
    procedure dodaj_agenta(p_nazwa_agenta varchar2,p_autonum BOOLEAN:=FALSE) IS
    BEGIN
        dodaj_agenta_hurt(1,p_nazwa_agenta,p_autonum); --dodaj 1 agenta
    END;
--------------------------------------------------------------------

--------------------------------------------------------------------
function wylosuj_agenta return  number IS
        v_nr_agenta number;
        v_max       number;
        v_pozycja   number; 
    BEGIN
    
        select count(*) into v_max from agenci;
        v_pozycja:=trunc(dbms_random.value(1,v_max+0.99)); --pozycja wiersza na liscie agentow
        select nr_agenta into v_nr_agenta from agenci order by nr_agenta desc offset v_pozycja-1 rows fetch first 1 rows only;
        return v_nr_agenta;
    END wylosuj_agenta;
--------------------------------------------------------------------
end agenci_pkg;
/