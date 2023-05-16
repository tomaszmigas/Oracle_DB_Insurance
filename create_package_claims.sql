PROMPT Tworzenie pakietu Szkody(spec)...
create or replace package szkody_pkg is
    procedure dodaj_szkode (p_nr_polisy number, p_id_osoby number, p_data_zajscia date, p_data_zglosz date, p_id_status number,p_wart_wyplaty number);
    procedure dodaj_szkode_ilosc_hurt (p_ilosc_szkod number, p_max_ilosc_szkod_na_polisie number);
    procedure dodaj_szkode_proc_hurt (p_proc_szkod number, p_max_ilosc_szkod number);
end szkody_pkg;
/

PROMPT Tworzenie pakietu Szkody(body)...
create or replace package body szkody_pkg is

---------------------------------------------
    procedure dodaj_szkode (p_nr_polisy number, p_id_osoby number, p_data_zajscia date, p_data_zglosz date, p_id_status number,p_wart_wyplaty number) IS
        e_zla_data exception;
        e_zle_wartosci_dat exception;
        e_zla_osoba exception;
        e_zly_status exception;
        v_id_osoby number;
        v_roznica_dat number;
    begin
        --sprawdz czy osoba istnieje na polisie
        SELECT count(id_osoby) into v_id_osoby from kontrahenci where nr_polisy = p_nr_polisy and id_osoby=p_id_osoby;
        dbms_output.put_line('v_id_osoby = ' || v_id_osoby);
        IF v_id_osoby = 0 THEN
            RAISE e_zla_osoba;
        END IF;
        
        --sprawdz czy data zajscia < data_do polisy
        SELECT p_data_zglosz-data_od into v_roznica_dat from polisy where nr_polisy = p_nr_polisy;
        dbms_output.put_line('v_roznica_dat = ' || v_roznica_dat);
        IF v_roznica_dat <0 THEN
            RAISE e_zla_data;
        END IF;
        
        --sprawdz czy daty zgloszenia i szkody s¹ ok
        IF p_data_zglosz - p_data_zajscia  <0 THEN
            RAISE e_zle_wartosci_dat;
        END IF;
        
        --sprawdz czy wyplata jest tylko dla statusu 4
        IF (p_id_status !=4 AND p_wart_wyplaty!=0) OR p_wart_wyplaty<0 THEN 
            RAISE e_zly_status;
        END IF;
        
        --wprowadzanie danych
        insert into szkody (nr_polisy, id_osoby,data_zajscia, data_zgloszenia,id_status, wartosc_wyplaty)
        VALUES (p_nr_polisy, p_id_osoby, p_data_zajscia, p_data_zglosz,p_id_status, p_wart_wyplaty);
        
        if sql%rowcount>0 THEN
            dbms_output.put_line('Szkoda zostala utworzona');
        else
            dbms_output.put_line('Szkoda nie zostala utworzona');
        end if;
		commit;
    exception
        when e_zla_osoba then
            dbms_output.put_line('Dodaj szkode - Exception Zla Osoba , na polisie ' || p_nr_polisy || ' nie ma osoby o id = ' || p_id_osoby);
            
            when e_zla_data then
            dbms_output.put_line('Dodaj szkode - Exception Zla Data , szkoda nie mo¿e byæ zg³oszona wczeœniej ni¿ data pocz¹tku polisy');
            
            when e_zle_wartosci_dat then
            dbms_output.put_line('Dodaj szkode - Exception Zle wartosci dat, data zg³oszenia szkody nie mo¿e byæ starsza ni¿ data zajœcia szkody');
            
            when e_zly_status then
            dbms_output.put_line('Dodaj szkode - Exception Zly status szkody lub zla kwota, wprowadzono kwotê wyp³aty <0 lub >0 dla szkody która nie ma statusu 4 (WYP£ACONA)');
    
        when others then
            dbms_output.put_line('Dodaj szkode - exception Others');
            dbms_output.put_line('sqlcode: ' || sqlcode);
            dbms_output.put_line('sqlerrm: ' || sqlerrm);
    end dodaj_szkode;
----------------------------------------------

----------------------------------------------
procedure dodaj_szkode_ilosc_hurt (p_ilosc_szkod number, p_max_ilosc_szkod_na_polisie number) IS
    TYPE t_polisy IS TABLE OF polisy.nr_polisy%TYPE;
    TYPE t_szkody IS TABLE OF szkody%rowtype;
    TYPE t_osoby IS TABLE OF  osoby.id_osoby%type;
    t_polisy_tab t_polisy:=t_polisy();                  -- kolekcja z nr polis
    t_szkody_tab t_szkody:=t_szkody();                  --kolekcja NT szkod
    t_osoby_tab t_osoby:=t_osoby();                     --kolekcja id_osob na wylosowanej polisie
    v_szkody szkody%rowtype;
    
    v_ilosc_szkod_calosc number:=0;                          --calkowita ilosc szkod
    v_ilosc_szkod_na_polisie number;
    v_nr_wiersza number;                              --wylosowany nr kolekcji
    v_nr_polisy number;                              --nr polisy
    v_id_osoby number;
    v_temp number;                                      --zmienna do przechowywania wartosci temp
    v_data_od_polisy date;
    v_data_do_polisy date;
    v_suma_ubezp_polisy number;
    v_data_zajscia date;
    v_data_zgloszenia date;
    
    
BEGIN
    SELECT nr_polisy bulk collect into t_polisy_tab  FROM polisy;
    
    WHILE v_ilosc_szkod_calosc<p_ilosc_szkod LOOP
        --losowy nr wiersza kolekcji z numerami polis
        v_nr_wiersza:=trunc(dbms_random.value(t_polisy_tab.first,t_polisy_tab.last)); 
        -- tu dostaje nr_polisy
        v_nr_polisy:=t_polisy_tab(v_nr_wiersza);        
        v_ilosc_szkod_na_polisie:=trunc(dbms_random.value(1,p_max_ilosc_szkod_na_polisie)); 
        
        --gdy ilosc szkod przekracza limit ogranicz ilosc szkod na ostatniej polisie
        IF v_ilosc_szkod_calosc + v_ilosc_szkod_na_polisie > p_ilosc_szkod THEN
            v_ilosc_szkod_na_polisie :=p_ilosc_szkod - v_ilosc_szkod_calosc;
        END IF;
        v_ilosc_szkod_calosc:=v_ilosc_szkod_calosc + v_ilosc_szkod_na_polisie;
        
        --czyszczenie kolekcji osob na danej polisie
        t_osoby_tab.delete;
        --kolekcja wszystkich id_osoby ktore wystepuja na danej polisie
        SELECT distinct id_osoby bulk collect into t_osoby_tab FROM kontrahenci where nr_polisy = v_nr_polisy;
    
--        dbms_output.put_line('Polisa nr: ' || v_nr_polisy || '   ilosc osob: ' || t_osoby_tab.count || '  ilosc szkod: ' || v_ilosc_szkod_na_polisie);

/*    
        dbms_output.put_line('Wylosowana polisa: ' || v_nr_polisy);
        dbms_output.put_line('Osoby na polisie:  ');
        for i in v_osoby.first..v_osoby.last LOOP
            dbms_output.put_line('id_osoby ' || i ||': ' || t_osoby_tab(i));
        END LOOP;
*/

--dbms_output.put_line('Polisa nr: ' || v_nr_polisy || '   ilosc osob: ' || t_osoby_tab.count || '  ilosc szkod: ' || v_ilosc_szkod_na_polisie);

        --dla kazdej szkody na polisie wylosuj osobe ktora ja zglasza 
        FOR i in 1..v_ilosc_szkod_na_polisie LOOP
                        
            v_szkody.nr_polisy:=v_nr_polisy;
            v_nr_wiersza:=trunc(dbms_random.value(t_osoby_tab.first,t_osoby_tab.last)); 
            v_szkody.id_osoby:=t_osoby_tab(v_nr_wiersza);
            
            select data_od,data_do,suma_ubezpieczenia into v_data_od_polisy,v_data_do_polisy,v_suma_ubezp_polisy from polisy where nr_polisy = v_nr_polisy;
            -- data zajscia szkody - od poczatku polisy do 30 dni po zakonczeniu (te po terminie beda odrzucane)
            v_szkody.data_zajscia:=generatory_pkg.generuj_date(v_data_od_polisy,v_data_do_polisy+30);
            
            v_szkody.data_zgloszenia:= v_szkody.data_zajscia + round(dbms_random.value(0,30)); 

            --korygowanie nieprawidlowosci po wygenerowaniu dat
            IF v_szkody.data_zgloszenia > current_date THEN --gdy data zgloszenia > bie¿acej daty
                v_szkody.data_zgloszenia:= to_date(current_date)-round(dbms_random.value(0,14));    -- cofnij date zgloszenia do bie¿acej daty lub do 14 dni wczesniej
                IF v_szkody.data_zgloszenia < v_szkody.data_zajscia THEN --gdy data zgloszenia < daty zajscia szkody
                    v_szkody.data_zajscia:=v_szkody.data_zgloszenia-round(dbms_random.value(0,30));    -- cofnij date zajscia 0-30 dni
                END IF;
                           
            END if;
        
--        /*
            -- szkoda zasz³a po okresie wa¿noœci polisy
            IF v_szkody.data_zajscia > v_data_do_polisy THEN
                v_szkody.id_status:=3; --odrzucona, zgloszona poza terminem polisy

            -- zasz³a w okresie wa¿noœci polisy, zgloszona przed koncem polisy i zgloszenie nast¹pilo do 5 dni od dzisiaj
            ELSIF v_szkody.data_zajscia < v_data_do_polisy and v_szkody.data_zgloszenia < v_data_do_polisy 
            AND current_date - v_szkody.data_zgloszenia <=5  THEN
                v_szkody.id_status:=1; --zgloszona, polisa wplynela do 5 dni od aktualnej daty

            -- zasz³a w okresie wa¿noœci polisy, zgloszona przed koncem polisy i zgloszenie nast¹pilo do 14 dni od dzisiaj
            ELSIF v_szkody.data_zajscia < v_data_do_polisy and v_szkody.data_zgloszenia < v_data_do_polisy 
            AND current_date - v_szkody.data_zgloszenia <=14  THEN
                v_szkody.id_status:=round(dbms_random.value(1.5,4.5)); --rozpatrywana odrzucona lub wyplacona
            
            -- zasz³a w okresie wa¿noœci polisy, zgloszona w dowolnym czasie
            ELSIF v_szkody.data_zajscia <= v_data_do_polisy THEN
                v_temp:=trunc(dbms_random.value(1,4));  -- odrzucona (1) lub wyplacona (2) 
                IF v_temp <=1 THEN                      -- 66% szans ¿e wyp³acona
                    v_szkody.id_status:=3; --odrzucona
                ELSE
                    v_szkody.id_status:=4; --wyplacona
                END IF;
            END IF;
      
--          */      

            IF v_szkody.id_status=4  THEN
                v_szkody.wartosc_wyplaty:=round(dbms_random.value(v_suma_ubezp_polisy/100,v_suma_ubezp_polisy));
            ELSE 
                v_szkody.wartosc_wyplaty:=0;
            END IF;
            
            t_szkody_tab.extend;
            t_szkody_tab(t_szkody_tab.last).id_szkody :=NULL;
            t_szkody_tab(t_szkody_tab.last).nr_polisy:=v_szkody.nr_polisy;
            t_szkody_tab(t_szkody_tab.last).id_osoby:=v_szkody.id_osoby;
            t_szkody_tab(t_szkody_tab.last).data_zajscia:=v_szkody.data_zajscia;
            t_szkody_tab(t_szkody_tab.last).data_zgloszenia:=  v_szkody.data_zgloszenia;
            t_szkody_tab(t_szkody_tab.last).id_status:=v_szkody.id_status;
            t_szkody_tab(t_szkody_tab.last).wartosc_wyplaty:=v_szkody.wartosc_wyplaty;

/*        
dbms_output.put_line(
'    Polisa nr ' || v_nr_polisy || 
'    Szkoda nr ' || i || '  data_zaj: ' || v_szkody.data_zajscia
|| ' data_zglosz: ' || v_szkody.data_zgloszenia
|| ' roznica dni: ' || (v_szkody.data_zgloszenia - v_szkody.data_zajscia)
);
*/
        END LOOP; --koniec dla kazdej szkody na polisie
        
    END LOOP;      --while

--/*
FORALL i IN t_szkody_tab.FIRST..t_szkody_tab.LAST
    INSERT INTO szkody VALUES t_szkody_tab(i);

--*/

--/*
    dbms_output.put_line('Dodano hurtowo szkody. Ilosc szkod: ' || t_szkody_tab.count);
--*/

null;
commit;
END  dodaj_szkode_ilosc_hurt;

----------------------------------------------
procedure dodaj_szkode_proc_hurt (p_proc_szkod number, p_max_ilosc_szkod number) IS
begin
    null;
end dodaj_szkode_proc_hurt;

----------------------------------------------
end szkody_pkg;
/

