PROMPT Tworzenie pakietu Polisy(spec)...
create or replace package polisy_pkg is
procedure dodaj_polise(p_nr_agenta number, p_data_pol_od date, p_data_pol_do date,p_skladka number, p_suma_ubezp number);
    procedure dodaj_polise_hurt (p_ilosc_polis number, p_ilosc_osob number, p_data_pol_od date, p_data_pol_do date, p_skladka_proc number, p_suma_min number,
    p_suma_max number, p_procent number);
end;
/

PROMPT Tworzenie pakietu Polisy(body)...
create or replace package body polisy_pkg is

----------------------------------------------
     procedure dodaj_polise(p_nr_agenta number, p_data_pol_od date, p_data_pol_do date,p_skladka number, p_suma_ubezp number) IS
    begin
        insert into polisy (NR_AGENTA,DATA_OD,DATA_DO,SKLADKA,SUMA_UBEZPIECZENIA)
        values (p_nr_agenta, p_data_pol_od, p_data_pol_do, p_skladka, p_suma_ubezp);
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
procedure dodaj_polise_hurt (p_ilosc_polis number, p_ilosc_osob number, p_data_pol_od date, p_data_pol_do date, p_skladka_proc number, p_suma_min number,
    p_suma_max number, p_procent number) IS
    TYPE polisy_tab IS TABLE OF polisy%rowtype;
    TYPE osoby_tab IS TABLE OF osoby%rowtype;
    TYPE kontrahenci_tab IS TABLE OF kontrahenci%rowtype;
    v_polisy polisy_tab:=polisy_tab();                  --kolekcja NT polis
    v_osoby osoby_tab:=osoby_tab();                     --kolekcja NT osob
    v_kontrahenci kontrahenci_tab:=kontrahenci_tab();   --kolekcja NT kontrahentow
    v_ostatnia_polisa number;
    v_ostatnia_osoba number;
    v_ilosc_osob_na_polisie number;
    v_dane_osobowe generatory_pkg.wiersz;               --dane osobowe
    v_temp number;                                      --zmienna do przechowywania wartosci temp

BEGIN
    select max(nr_polisy) into v_ostatnia_polisa from polisy;
    select max(id_osoby) into v_ostatnia_osoba from osoby;
    
    if v_ostatnia_polisa is null then v_ostatnia_polisa:=0; end if;
    if v_ostatnia_osoba is null then v_ostatnia_osoba:=0; end if;
    
    for i IN 1..p_ilosc_polis LOOP      --wykonaj dla kazdej generowanej polisy
        v_ostatnia_polisa:=v_ostatnia_polisa+1;
        
    --wypelnienie kolekcji polisy
        v_polisy.extend;
        v_polisy(v_polisy.last).nr_polisy:=v_ostatnia_polisa;
        v_polisy(v_polisy.last).nr_agenta:=agenci_pkg.wylosuj_agenta;   
        v_polisy(v_polisy.last).data_od:=generatory_pkg.generuj_date(p_data_pol_od,p_data_pol_do);
        v_polisy(v_polisy.last).data_do:=v_polisy(v_polisy.last).data_od + INTERVAL '364' DAY;
        v_polisy(v_polisy.last).suma_ubezpieczenia:=generatory_pkg.generuj_sume_ubezp(p_suma_min,p_suma_max);
        v_polisy(v_polisy.last).skladka:=v_polisy(v_polisy.last).suma_ubezpieczenia*p_skladka_proc/100;
/*    
    dbms_output.put_line('-----------------------------');
    dbms_output.put_line('polisa nr : '  || v_polisy.count);
*/  

    --------------- generowanie osob do polisy --------------------
    --generowanie losowej ilosci osob na polisie
        v_ilosc_osob_na_polisie := round(dbms_random.value(1,p_ilosc_osob));
    
    --najpierw ubezpieczajacy --> jest na polisie zawsze
        v_ostatnia_osoba := v_ostatnia_osoba +1;
        
		--osoba ubezpieczajaca ma w momencie utworzenia polisy 18-80 lat i taki pesel jest generowany
        v_dane_osobowe.pesel:=generatory_pkg.generuj_pesel(v_polisy(v_polisy.last).data_od - interval '29200' DAY ,v_polisy(v_polisy.last).data_od - interval '6570' DAY);
		v_dane_osobowe:=generatory_pkg.generuj_dane_osobowe(v_dane_osobowe.pesel);
        v_dane_osobowe.id_osoby:=v_ostatnia_osoba;
    
        v_osoby.extend;
        v_osoby(v_osoby.last):=v_dane_osobowe;
      
    --pierwszy kontrahent jako ubezepieczajacy
        v_kontrahenci.extend;
        v_kontrahenci(v_kontrahenci.last).nr_polisy:=v_polisy(v_polisy.last).nr_polisy;
        v_kontrahenci(v_kontrahenci.last).id_osoby:=v_osoby(v_osoby.last).id_osoby;
        v_kontrahenci(v_kontrahenci.last).id_roli:=1;
    /*    
        dbms_output.put_line('Osoba ubezpieczajaca - pesel: ' || v_dane_osobowe.pesel || 
        ' imie: ' || v_dane_osobowe.imie || ' nazwisko: ' || v_dane_osobowe.nazwisko );
    */
    --pierwsza ubezpieczona osoba na polisie to na 100% ubezpieczajacy (zmienna p_procent)


        for i in 1..v_ilosc_osob_na_polisie LOOP  -- umiescic wewnatrz loop polisy
            IF i = 1 THEN
                v_temp:= round(dbms_random.value(0,100));
                IF v_temp<=p_procent THEN 
                    -- je¿eli pierwszy ubezpieczony to osoba ubezpieczajaca
                    v_kontrahenci.extend;
                    v_kontrahenci(v_kontrahenci.last).nr_polisy:=v_polisy(v_polisy.last).nr_polisy;
                    v_kontrahenci(v_kontrahenci.last).id_osoby:=v_osoby(v_osoby.last).id_osoby;
                    v_kontrahenci(v_kontrahenci.last).id_roli:=2;
                ELSE
                    --je¿eli pierwszy ubezpieczony to inna osoba niz ubezpieczajacy
                    v_ostatnia_osoba := v_ostatnia_osoba +1;
                    
					--osoba ubezpieczona ma w momencie utworzenia polisy 0-80 lat i taki pesel jest generowany
                    v_dane_osobowe.pesel:=generatory_pkg.generuj_pesel(v_polisy(v_polisy.last).data_od - interval '29200' DAY ,v_polisy(v_polisy.last).data_od);
                    
					
					v_dane_osobowe:=generatory_pkg.generuj_dane_osobowe(v_dane_osobowe.pesel);
                    v_dane_osobowe.id_osoby:=v_ostatnia_osoba;
                    v_osoby.extend;
                    v_osoby(v_osoby.last):=v_dane_osobowe;
                      
                    v_kontrahenci.extend;
                    v_kontrahenci(v_kontrahenci.last).nr_polisy:=v_polisy(v_polisy.last).nr_polisy;
                    v_kontrahenci(v_kontrahenci.last).id_osoby:=v_osoby(v_osoby.last).id_osoby;
                    v_kontrahenci(v_kontrahenci.last).id_roli:=2;
                END IF; -- koniec IF dla pierwszej osoby na polisie
            ELSE -- dla 2 lub kolejnej osoby
                    --kolejny ubezpieczony jest zawsze jako inna osoba ni¿ ubezpieczajacy
                    v_ostatnia_osoba := v_ostatnia_osoba +1;
                    
					--osoba ubezpieczona ma w momencie utworzenia polisy 0-80 lat i taki pesel jest generowany
                    v_dane_osobowe.pesel:=generatory_pkg.generuj_pesel(v_polisy(v_polisy.last).data_od - interval '29200' DAY ,v_polisy(v_polisy.last).data_od);
                    
					
					v_dane_osobowe:=generatory_pkg.generuj_dane_osobowe(v_dane_osobowe.pesel);
                    v_dane_osobowe.id_osoby:=v_ostatnia_osoba;
                    v_osoby.extend;
                    v_osoby(v_osoby.last):=v_dane_osobowe;
                      
                    v_kontrahenci.extend;
                    v_kontrahenci(v_kontrahenci.last).nr_polisy:=v_polisy(v_polisy.last).nr_polisy;
                    v_kontrahenci(v_kontrahenci.last).id_osoby:=v_osoby(v_osoby.last).id_osoby;
                    v_kontrahenci(v_kontrahenci.last).id_roli:=2;
            END IF;
        
/*
            dbms_output.put_line('Osoba ubezpieczana ' || i || ' - pesel: ' || v_dane_osobowe.pesel || 
            ' imie: ' || v_dane_osobowe.imie || 
            ' nazwisko: ' || v_dane_osobowe.nazwisko );
*/
        end loop; -- koniec for ilosc osob na polisie

    end loop; --koniec for polisy

--pola wypelnionych kolekcji
/*
    dbms_output.put_line('');
    dbms_output.put_line('Dane kolekcji v_osoby:');
    for i in v_osoby.first..v_osoby.last LOOP
        dbms_output.put_line(i || ':  id_osoby: ' || v_osoby(i).id_osoby || ':  imie : ' || lpad(v_osoby(i).imie,15,' ') 
        || ':  nazwisko : ' || lpad(v_osoby(i).nazwisko,15,' ') || ':  pesel : ' || v_osoby(i).pesel);
    END LOOP;
    
    dbms_output.put_line('');
    dbms_output.put_line('Dane kolekcji v_kontrahenci:');
    for i in v_kontrahenci.first..v_kontrahenci.last LOOP
        dbms_output.put_line(i || ':  nr_polisy: ' || v_kontrahenci(i).nr_polisy 
        || ':  id_osoby : ' || v_kontrahenci(i).id_osoby || ':  id_roli : ' || v_kontrahenci(i).id_roli );
    END LOOP;
*/


FORALL i IN v_polisy.FIRST..v_polisy.LAST
    INSERT INTO polisy VALUES v_polisy(i);
        
FORALL i IN v_osoby.FIRST..v_osoby.LAST
    INSERT INTO osoby VALUES v_osoby(i);

FORALL i IN v_kontrahenci.FIRST..v_kontrahenci.LAST
    INSERT INTO kontrahenci VALUES v_kontrahenci(i);

-- dbms_output.put_line('Dodano hurtowo polisy. Ilosc polis: ' || v_polisy.count || '  Ilosc osob: ' || v_osoby.count);



commit;
END  dodaj_polise_hurt;

----------------------------------------------

end polisy_pkg;
/

