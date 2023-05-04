PROMPT Tworzenie pakietu Generatory (spec)...
CREATE OR REPLACE 
PACKAGE GENERATORY_PKG AS 
    TYPE wiersz is RECORD (
        imie varchar2(50),
        nazwisko varchar2(50),
        pesel varchar2(11)
    );
    
    function generuj_date(p_data_od date, p_data_do date) return date;
    function generuj_pesel(p_data_od date, p_data_do date) return varchar2;
--    function generuj_dane_osobowe(p_plec CHAR) return wiersz;
    function generuj_dane_osobowe(p_pesel VARCHAR2) return wiersz;
    function generuj_sume_ubezp(p_suma_min number, p_suma_max number) return number;
     

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END GENERATORY_PKG;
/
----------------------------------------
PROMPT Tworzenie pakietu Generatory (body)...
CREATE OR REPLACE PACKAGE BODY GENERATORY_PKG AS
-----------------------------------------
  function generuj_date(p_data_od date, p_data_do date) return date AS
    v_data_od number;
    v_data_do number;
    v_data varchar2(50);
  BEGIN
    SELECT to_char(p_data_od,'J') into v_data_od from dual;     -- zamien date na liczbe dni
    SELECT to_char(p_data_do,'J') into v_data_do from dual;     -- zamien date na liczbe dni
    v_data:=trunc(dbms_random.value(v_data_od,v_data_do));      -- wygeneruj liczbe losowa z podanego zakresu, obetnij do calosci
    v_data:=to_date(v_data,'J');                                -- zamien wylosowana liczbe z powrotem na date
    RETURN v_data;
  END generuj_date;
-----------------------------------------

-----------------------------------------
 function generuj_pesel(p_data_od date, p_data_do date) return varchar2 AS
    v_data date;
    v_pesel varchar2(20);
    v_liczba_kontrolna number:=0;
    v_mnoznik number;
    v_temp number;
    v_temp2 varchar2(10);
  BEGIN
    v_data:=generuj_date(p_data_od, p_data_do);
--    dbms_output.put_line('Data: ' || v_data);
    IF EXTRACT(year from v_data) > 1899  AND EXTRACT(year from v_data) < 2000 THEN
        v_pesel:= to_char(v_data,'YYMMDD');
    ELSIF EXTRACT(year from v_data) < 2100 THEN
        v_pesel:= to_char(v_data,'YY') || (extract(month from v_data)+20) || to_char(v_data,'DD'); --inaczej liczy miesiąc
    ELSE 
        RAISE_APPLICATION_ERROR(-20999,'Nieobsługiwany zakres dat');
    END IF;
        v_pesel:=v_pesel || LTRIM(to_char(trunc(dbms_random.value(1,9999)),'0000'));
        dbms_output.put_line( 'v_pesel: ' || v_pesel);   
        for i in 1..10 LOOP
            v_mnoznik:=case
                WHEN i = 1 OR i=5 OR i=9    THEN 1
                WHEN i = 2 OR i=6 OR i=10   THEN 3
                WHEN i = 3 OR i=7           THEN 7
                WHEN i = 4 OR i=8           THEN 9
            end;
         dbms_output.put_line( 'Skladnik(' || i || '): ' || substr(v_pesel,i,1) || ' * ' || v_mnoznik || ' = '    || substr(substr(v_pesel,i,1)*v_mnoznik,-1,1));   
        v_liczba_kontrolna:=v_liczba_kontrolna + substr(substr(v_pesel,i,1)*v_mnoznik,-1,1);
            --wynik jako suma mnozenia skladowych pesela przez wagi (tylko pola jednosci biorą udział)
        END LOOP;
        dbms_output.put_line( 'Suma dla liczby kontrolnej: ' || v_liczba_kontrolna);   
        dbms_output.put_line( 'Obcieta Suma dla liczby kontrolnej: ' || substr(v_liczba_kontrolna,-1,1));   
        IF substr(v_liczba_kontrolna,-1,1) = 0 THEN --gdy suma to pelne dziesiatki (ryzyko 12 znakow 
            v_liczba_kontrolna:=0;
        ELSE
            v_liczba_kontrolna:=10-substr(v_liczba_kontrolna,-1,1); --bierzemy tylko cyfrę jednosci
        END IF;
        v_pesel:=v_pesel || v_liczba_kontrolna;
        
    RETURN v_pesel;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Exception dla ''Generuj PESEL'', sqlcode: ' || sqlcode);
            dbms_output.put_line('SQLCode: ' || sqlcode || '  sqlerrm: ' ||sqlerrm);
            return -1;
    
  END generuj_pesel;
-----------------------------------------

-----------------------------------------
/*
  function generuj_dane_osobowe(p_plec CHAR) return wiersz AS
  BEGIN
    -- TODO: Implementation required for function GENERATORY_PKG.generuj_dane_osobowe
    RETURN NULL;
  END generuj_dane_osobowe;
*/
-----------------------------------------

-----------------------------------------
function generuj_dane_osobowe(p_pesel VARCHAR2) return wiersz AS
    v_plec char;
    v_dane wiersz;
    v_zakres integer;
    v_pozycja integer;
  BEGIN
        -- jezeli 10 cyfra numeru pesel pokazuje na kobiete
    IF substr(p_pesel,10,1) IN (0,2,4,6,8) THEN 
          select count(*) into v_zakres from imiona_zenskie; 
          select dbms_random.value(1,v_zakres) into v_pozycja from dual;
          SELECT imie into v_dane.imie from imiona_zenskie where id = v_pozycja;
          
          select count(*) into v_zakres from nazwiska_zenskie; 
          select dbms_random.value(1,v_zakres) into v_pozycja from dual;
          SELECT nazwisko into v_dane.nazwisko from nazwiska_zenskie where id = v_pozycja;
          v_dane.pesel:=p_pesel;
    ELSE
            -- gdy pesel pokazuje na mezczyzne
          select count(*) into v_zakres from imiona_meskie; 
          select dbms_random.value(1,v_zakres) into v_pozycja from dual;
          SELECT imie into v_dane.imie from imiona_meskie where id = v_pozycja;
          
          select count(*) into v_zakres from nazwiska_meskie; 
          select dbms_random.value(1,v_zakres) into v_pozycja from dual;
          SELECT nazwisko into v_dane.nazwisko from nazwiska_meskie where id = v_pozycja;
          v_dane.pesel:=p_pesel;
        END IF;
    RETURN v_dane;
  END generuj_dane_osobowe;
-----------------------------------------


-----------------------------------------
  function generuj_sume_ubezp(p_suma_min number, p_suma_max number) return number AS
    v_suma number:=0;
  BEGIN
    v_suma:= trunc(dbms_random.value(p_suma_min,p_suma_max));
    RETURN v_suma;
  END generuj_sume_ubezp;
-----------------------------------------
END GENERATORY_PKG;
/