PROMPT Tworzenie pakietu Agenci (spec)..
create or replace package agenci_pkg is
    procedure dodaj_agentow_hurt(p_nazwa_agenta varchar2 default 'Agent',p_ilosc number:=1,p_autonum BOOLEAN:=TRUE);
    procedure dodaj_agenta(p_nazwa_agenta varchar2,p_autonum BOOLEAN:=FALSE);
end;
/

PROMPT Tworzenie pakietu Agenci (body)..
create or replace package body agenci_pkg is

--------------------------------------------------------------------    
 
    procedure ustaw_seq(p_max_agent OUT number) IS
    BEGIN
        select max(nr_agenta) into p_max_agent from agenci;  -- p_max_agent = max nr wiersza w tabeli agenci
                          
        if p_max_agent >0 then --jezeli istnieja wiersze w tabeli agenci to ustaw sekwencje na kolejny wiersz (nawet jak jest już ustawiona ok)
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

-- przy imporcie calego schematu tworzone sa od nowa obiekty w tym sekwencje, tabele moga juz zawierac dane
-- trzeba dopasowac wartosc startowa sekwencji do ilosci wierszy
    
    procedure dodaj_agentow_hurt(p_nazwa_agenta varchar2 default 'Agent',p_ilosc number:=1,p_autonum BOOLEAN:=TRUE) IS
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
    exception
        when others then
            dbms_output.put_line('Agenci_pkg.Dodaj_agentow - wyjatek Others');
            dbms_output.put_line('SQLCode: ' || sqlcode || '   SQL Errm: ' || sqlerrm);
            rollback;
    commit;
    end dodaj_agentow_hurt;

    procedure dodaj_agenta(p_nazwa_agenta varchar2,p_autonum BOOLEAN:=FALSE) IS
    BEGIN
        dodaj_agentow_hurt(p_nazwa_agenta,1,p_autonum); --dodaj 1 agenta
    END;


end agenci_pkg;
commit;
/