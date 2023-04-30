PROMPT Tworzenie pakietu Polisy(spec)...
create or replace package polisy_pkg is
    procedure wprowadz_polise (p_nr_agenta number, p_data_od date, p_data_do date, p_skladka number, p_suma_ubezpieczenia number);
--    procedure wprowadz_osobe(nazwisko varchar2,imie varchar2, pesel number, rola varchar2);
end;
/

PROMPT Tworzenie pakietu Polisy(body)...
create or replace package body polisy_pkg is
    procedure wprowadz_polise(p_nr_agenta number, p_data_od date, p_data_do date, p_skladka number, p_suma_ubezpieczenia number) IS
    begin
        insert into polisy NR_POLISY (NR_AGENTA,DATA_OD,DATA_DO,SKLADKA,SUMA_UBEZPIECZENIA) 
        values (p_nr_agenta, p_data_od, p_data_do, p_skladka, p_suma_ubezpieczenia);
        if sql%rowcount>0 THEN
            dbms_output.put_line('Polisa zostala utworzona');
        else 
            dbms_output.put_line('Polisa nie zostala utworzona');
        end if;
        null;
    exception
        when others then 
            dbms_output.put_line('Wprowadz polise - exception Others');
            dbms_output.put_line('sqlcode: ' || sqlcode);
            dbms_output.put_line('sqlerrm: ' || sqlerrm);
        
    end wprowadz_polise;
    
--    procedure wprowadz_osobe(nazwisko varchar2,imie varchar2, pesel number, rola varchar2) IS
--    begin
--        insert into polisy NR_POLISY (NR_AGENTA,DATA_OD,DATA_DO,SKLADKA,SUMA_UBEZPIECZENIA) 
--        values (p_nr_agenta, p_data_od, p_data_do, p_skladka, p_suma_ubezpieczenia);
--        if sql%rowcount>0 THEN
--            dbms_output.put_line('Polisa zostala utworzona');
--        else 
--            dbms_output.put_line('Polisa nie zostala utworzona');
--        end if;
--    end wprowadz_osobe;
end;
/
