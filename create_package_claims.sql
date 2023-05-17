PROMPT Tworzenie pakietu Szkody(spec)...
create or replace package szkody_pkg is
    procedure dodaj_szkode (p_nr_polisy number, p_id_osoby number, p_data_zajscia date, p_data_zglosz date, p_id_status number,p_wart_wyplaty number);
    procedure dodaj_szkode_hurt (p_ilosc_szkod number, p_max_ilosc_szkod_na_polisie number);
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
procedure dodaj_szkode_hurt (p_ilosc_szkod number, p_max_ilosc_szkod_na_polisie number) IS
    TYPE t_polisy IS TABLE OF polisy.nr_polisy%TYPE;
    TYPE t_szkody IS TABLE OF szkody%rowtype;
    TYPE t_osoby IS TABLE OF  osoby.id_osoby%type;
    t_polisy_tab t_polisy:=t_polisy();                  -- kolekcja z nr polis
    t_szkody_tab t_szkody:=t_szkody();                  -- kolekcja NT szkod
    t_osoby_tab t_osoby:=t_osoby();                     -- kolekcja id_osob na wylosowanej polisie
    v_szkody szkody%rowtype;                            -- rekord do zbierania danych szkody w bie¿¹cym kroku
    
    v_ilosc_szkod_suma integer:=0;                      -- suma wygenerowanych szkod dla wszystkich polis
    v_ilosc_szkod_na_polisie integer;                   -- wylosowana ilosc szkod na 1 polisie
    v_nr_wiersza integer;                               -- wylosowany nr wybranej kolekcji
    v_nr_polisy number;                                 
    v_id_osoby number;                                  
    v_temp number;                                      -- zmienna do przechowywania wartosci temp
    v_data_od_polisy date;                              -- data startowa wylosowanej polisy
    v_data_do_polisy date;                              -- data koncowa wylosowanej polisy
    v_suma_ubezp_polisy number;                         -- suma ubezp wylosowanej polisy
    v_data_zajscia date;
    v_data_zgloszenia date;
    
    
BEGIN
    SELECT nr_polisy BULK COLLECT INTO t_polisy_tab FROM polisy;
    
    WHILE v_ilosc_szkod_suma<p_ilosc_szkod LOOP
        
        
        v_nr_wiersza:=dbms_random.value(t_polisy_tab.first,t_polisy_tab.last);          -- losowy nr wiersza z kolekcji z numerami polis
        v_nr_polisy:=t_polisy_tab(v_nr_wiersza);                                        -- pobierz nr_polisy
        v_ilosc_szkod_na_polisie:=dbms_random.value(1,p_max_ilosc_szkod_na_polisie);    -- wylosuj ilosc szkod na polisie
        
        IF v_ilosc_szkod_suma + v_ilosc_szkod_na_polisie > p_ilosc_szkod THEN           -- gdy ilosc szkod przekracza limit 
            v_ilosc_szkod_na_polisie :=p_ilosc_szkod - v_ilosc_szkod_suma;              -- ogranicz ilosc szkod na ostatniej polisie
        END IF;
        v_ilosc_szkod_suma:=v_ilosc_szkod_suma + v_ilosc_szkod_na_polisie;
        
        t_osoby_tab.delete;                                                              -- czyszczenie kolekcji osob na danej polisie
        SELECT distinct id_osoby bulk collect into t_osoby_tab FROM kontrahenci where nr_polisy = v_nr_polisy; -- kolekcja wszystkich id_osoby ktore wystepuja na danej polisie
    
-- dbms_output.put_line('Polisa nr: ' || v_nr_polisy || '   ilosc osob: ' || t_osoby_tab.count || '  ilosc szkod: ' || v_ilosc_szkod_na_polisie);
/*    
        dbms_output.put_line('Wylosowana polisa: ' || v_nr_polisy);
        dbms_output.put_line('Osoby na polisie:  ');
        for i in v_osoby.first..v_osoby.last LOOP dbms_output.put_line('id_osoby ' || i ||': ' || t_osoby_tab(i)); END LOOP;
*/
        
        FOR i in 1..v_ilosc_szkod_na_polisie LOOP    --dla kazdej szkody na polisie wylosuj osobe ktora ja zglasza 
                        
            v_szkody.nr_polisy:=v_nr_polisy;
            v_nr_wiersza:=dbms_random.value(t_osoby_tab.first,t_osoby_tab.last); 
            v_szkody.id_osoby:=t_osoby_tab(v_nr_wiersza);
           
            select data_od,data_do,suma_ubezpieczenia into v_data_od_polisy,v_data_do_polisy,v_suma_ubezp_polisy from polisy where nr_polisy = v_nr_polisy;
            
            v_szkody.data_zajscia:=generatory_pkg.generuj_date(v_data_od_polisy,v_data_do_polisy+30); -- data zajscia szkody - od poczatku polisy do 30 dni po zakonczeniu
            v_szkody.data_zgloszenia:= v_szkody.data_zajscia + round(dbms_random.value(0,30));      -- data zgloszenia - data zajscia + 0-30 dni

            --korygowanie nieprawidlowosci po wygenerowaniu dat zgloszen
            IF v_szkody.data_zgloszenia > current_date THEN                                         -- gdy data zgloszenia > bie¿acej daty
                v_szkody.data_zgloszenia:= to_date(current_date)-round(dbms_random.value(0,7));    -- cofnij date zgloszenia do bie¿acej daty lub do 0 - 14 dni wczesniej
                IF v_szkody.data_zgloszenia < v_szkody.data_zajscia THEN                            -- gdy data zgloszenia < daty zajscia szkody
                    v_szkody.data_zajscia:=v_szkody.data_zgloszenia-round(dbms_random.value(0,14)); -- cofnij date zajscia 0-14 dni
                END IF;
                           
            END if;
            
            IF v_szkody.data_zajscia > v_data_do_polisy THEN
                v_szkody.id_status:=3;                                      -- szkoda odrzucona, zgloszona poza terminem polisy
            
            ELSIF v_szkody.data_zajscia <= v_data_do_polisy and v_szkody.data_zgloszenia <= v_data_do_polisy AND current_date - v_szkody.data_zgloszenia <=5  THEN
                v_szkody.id_status:=1;                                      -- zgloszonaw terminie, polisa wplynela do 5 dni od aktualnej daty

            ELSIF v_szkody.data_zajscia <= v_data_do_polisy and v_szkody.data_zgloszenia <= v_data_do_polisy AND current_date - v_szkody.data_zgloszenia <=14  THEN
                v_szkody.id_status:=2;                                      -- zgloszona w terminie, minelo do 14 dni rozpatrywana
            
            ELSIF v_szkody.data_zajscia <= v_data_do_polisy THEN            -- zgloszona w terminie
                v_temp:=trunc(dbms_random.value(0.5,4.5));                  -- losowanie czy odrzucona (1) lub wyplacona (2) 
                IF v_temp <=1 THEN                                          -- 75% szans ¿e wyp³acona
                    v_szkody.id_status:=3;                                  -- odrzucona
                ELSE
                    v_szkody.id_status:=4;                                  -- wyplacona
                END IF;
            END IF;

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
    END LOOP;      --koniec while

FORALL i IN t_szkody_tab.FIRST..t_szkody_tab.LAST
    INSERT INTO szkody VALUES t_szkody_tab(i);

-- dbms_output.put_line('Dodano hurtowo szkody. Ilosc szkod: ' || t_szkody_tab.count);

commit;
EXCEPTION
    WHEN others THEN
            dbms_output.put_line('Dodaj szkode hurt - exception Others');
            dbms_output.put_line('sqlcode: ' || sqlcode);
            dbms_output.put_line('sqlerrm: ' || sqlerrm);

END  dodaj_szkode_hurt;

----------------------------------------------
end szkody_pkg;
/

