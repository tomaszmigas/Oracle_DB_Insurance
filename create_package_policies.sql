PROMPT Tworzenie pakietu Polisy(spec)...
create or replace package polisy_pkg is
    procedure dodaj_polise (p_nr_agenta number, p_data_od date, p_data_do date, p_suma_ubezpieczenia number);
    procedure dodaj_polise_hurt (p_ilosc_polis number, p_data_od date, p_data_do date, p_suma_min number,p_suma_max number,p_ilosc_osob number);
end;
/

PROMPT Tworzenie pakietu Polisy(body)...
create or replace package body polisy_pkg is

----------------------------------------------
     procedure dodaj_polise(p_nr_agenta number, p_data_od date, p_data_do date, p_suma_ubezpieczenia number) IS
    begin
        insert into polisy (NR_AGENTA,DATA_OD,DATA_DO,SKLADKA,SUMA_UBEZPIECZENIA)
        values (p_nr_agenta, p_data_od, p_data_do, p_suma_ubezpieczenia*0.1, p_suma_ubezpieczenia);
        if sql%rowcount>0 THEN
            dbms_output.put_line('Polisa zostala utworzona');
        else
            dbms_output.put_line('Polisa nie zostala utworzona');
        end if;
		commit;
    exception
        when others then
            dbms_output.put_line('Wprowadz polise - exception Others');
            dbms_output.put_line('sqlcode: ' || sqlcode);
            dbms_output.put_line('sqlerrm: ' || sqlerrm);
    end dodaj_polise;
----------------------------------------------

----------------------------------------------
procedure dodaj_polise_hurt (p_ilosc_polis number, p_data_od date, p_data_do date, p_suma_min number, p_suma_max number,p_ilosc_osob number) IS
    TYPE polisy_tab IS TABLE OF polisy%rowtype;
    TYPE osoby_tab IS TABLE OF osoby%rowtype;
    TYPE kontrahenci_tab IS TABLE OF kontrahenci%rowtype;
    v_polisy polisy_tab:=polisy_tab();                  --kolekcja NT polis
    v_osoby osoby_tab:=osoby_tab();                     --kolekcja NT osob
    v_kontrahenci kontrahenci_tab:=kontrahenci_tab();   --kolekcja NT kontrahentow
    v_nr_agenta number;
    v_data_polisy_start date;
    v_data_polisy_koniec date;
    v_suma_ubezp number;
    v_skladka number;
BEGIN
for i IN 1..p_ilosc_polis LOOP      --wykonaj dla kazdej generowanej polisy
                                    --wypelnienie kolekcji polisy
    v_polisy.extend;
    v_polisy(v_polisy.last).nr_agenta:=agenci_pkg.wylosuj_agenta;   
    v_polisy(v_polisy.last).data_od:=generatory_pkg.generuj_date(p_data_od,p_data_do);
    v_polisy(v_polisy.last).data_do:=v_polisy(v_polisy.last).data_od + INTERVAL '364' DAY;
    v_polisy(v_polisy.last).suma_ubezpieczenia:=generatory_pkg.generuj_sume_ubezp(p_suma_min,p_suma_max);
    v_polisy(v_polisy.last).skladka:=v_polisy(v_polisy.last).suma_ubezpieczenia*0.05;
    
   
    
--    dbms_output.put_line('nr agenta: ' || v_nr_agenta);
--    dbms_output.put_line('data_s: ' || v_data_polisy_start);
--    dbms_output.put_line('data_k: ' || v_data_polisy_koniec);    
--    dbms_output.put_line('suma_ubezp: ' || v_suma_ubezp);
    
    END LOOP;
    
    for i in v_polisy.first..v_polisy.last loop
     dbms_output.put_line('i = ' || i || '  nr_agenta: ' || v_polisy(i).nr_agenta 
     || '   data_od: ' || v_polisy(i).data_od  || '   data_do: ' || v_polisy(i).data_do  
     || '   skladka: ' || v_polisy(i).skladka  || '   suma_ubezp: ' || v_polisy(i).suma_ubezpieczenia
     
     );
        end loop;

END  dodaj_polise_hurt;

----------------------------------------------

end polisy_pkg;
/

