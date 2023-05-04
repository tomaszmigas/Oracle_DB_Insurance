PROMPT Tworzenie pakietu Polisy(spec)...
create or replace package polisy_pkg is
    procedure dodaj_polise (p_nr_agenta number, p_data_od date, p_data_do date, p_suma_ubezpieczenia number);
    --procedure dodaj_polise_hurt (p_ilosc_polis number, p_data_od date, p_data_do date, p_max_suma_ubezp number,p_ilosc_osob number);
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
    exception
        when others then
            dbms_output.put_line('Wprowadz polise - exception Others');
            dbms_output.put_line('sqlcode: ' || sqlcode);
            dbms_output.put_line('sqlerrm: ' || sqlerrm);
    end dodaj_polise;
----------------------------------------------
/*
----------------------------------------------
 procedure dodaj_polise_hurt (p_ilosc_polis number, p_data_od date, p_data_do date, p_max_suma_ubezp number, p_ilosc_osob number) IS
        TYPE tabela IS TABLE OF generatory_pkg.wiersz index by pls_integer;
        tab1 tabela:=tabela();
    BEGIN  

    --polisy beda wpisywane do kolekcji polisy_tab
    --osoby beda wpisywane do kolekji osoby_tab
    --do kolekcji kontrahenci_tab beda wpisywane odpowiednie dane 
    

--      tab1:=wygeneneruj dane_polis(p_ilosc_polis,p_data_od,p_data_do,p_max_suma_ubezp);
            -- wylosuj agenta sposrod dostepnych
            -- wygeneruj date startowa z podanego zakresu dat
            -- wylosuj sume ubezp

--      wygeneruj_polisy uzywajac gotowej procedury dodaj_polise  i kolekcji tab1;
        
--losowe ilosci osob 1-max
--        wygeneruj_osoby_do_polis(p_ilosc_osob)
--            wygeneruj pesel
--            wygeneruj_imie oraz nazwizko ubezpieczajacego
--            wylosuj liczbe osob na polisie
    --            jezeli liczba osob >1 to wygeneruj i dodaj do polisy (poprzez kontrahenci) osoby o tym samym nazwisku 
    
    -- przepisz dane z kolekcji do odpwoiednich tabel
    
    for i IN 1..p_ilosc_polis LOOP  --dla kazdej generowanej polisy - chyba nie bede uzywal
            null;
    END LOOP;
    
    END  dodaj_polise_hurt;
----------------------------------------------
*/
end;
/

