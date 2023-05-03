CREATE OR REPLACE 
PACKAGE GENERATORY_PKG AS 
    TYPE wiersz is RECORD (
        imie varchar2(50),
        nazwisko varchar2(50),
        pesel varchar2(11)
    );
    
    function generuj_date(p_data_od date, p_data_do date) return date;
    function generuj_pesel(p_data_od date, p_data_do date) return varchar2;
    function generuj_dane_osobowe(p_plec CHAR) return wiersz;
    function generuj_dane_osobowe(p_pesel VARCHAR2) return wiersz;
    function generuj_sume_ubezp(p_suma_min number, p_suma_max number) return number;
     

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END GENERATORY_PKG;
/
----------------------------------------

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
  BEGIN
    v_data:=generuj_date(p_data_od, p_data_do);
    dbms_output.put_line('Data: ' || v_data);
    IF EXTRACT(year from v_data) > 1899  AND EXTRACT(year from v_data) < 2000 THEN
        v_pesel:= to_char(v_data,'YYMMDD');
    ELSIF EXTRACT(year from v_data) < 2100 THEN
        v_pesel:= to_char(v_data,'YY') || (extract(month from v_data)+20) || to_char(v_data,'DD'); --inaczej liczy miesiąc
    ELSE 
        RAISE_APPLICATION_ERROR(-20999,'Nieobsługiwany zakres dat');
    END IF;
        v_pesel:=v_pesel || trunc(dbms_random.value(0,9999));
        for i in 1..10 LOOP
            v_mnoznik:=case
                WHEN i = 1 OR i=5 OR i=9    THEN 1
                WHEN i = 2 OR i=6 OR i=10   THEN 3
                WHEN i = 3 OR i=7           THEN 7
                WHEN i = 4 OR i=8           THEN 9
            end;
        v_liczba_kontrolna:=v_liczba_kontrolna + substr(substr(v_pesel,i,1)*v_mnoznik,-1,1);
            --wynik jako suma mnozenia skladowych pesela przez wagi (tylko pola jednosci biorą udział)
        END LOOP;
        v_liczba_kontrolna:=10-substr(v_liczba_kontrolna,-1,1); --bierzemy tylko cyfrę jednosci
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
  function generuj_dane_osobowe(p_plec CHAR) return wiersz AS
  BEGIN
    -- TODO: Implementation required for function GENERATORY_PKG.generuj_dane_osobowe
    RETURN NULL;
  END generuj_dane_osobowe;
----------------------------------------

-----------------------------------------
function generuj_dane_osobowe(p_pesel VARCHAR2) return wiersz AS
  BEGIN
    -- TODO: Implementation required for function GENERATORY_PKG.generuj_dane_osobowe
    RETURN NULL;
  END generuj_dane_osobowe;
  -----------------------------------------



-----------------------------------------
  function generuj_sume_ubezp(p_suma_min number, p_suma_max number) return number AS
  BEGIN
    -- TODO: Implementation required for function GENERATORY_PKG.generuj_sume_ubezp
    RETURN NULL;
  END generuj_sume_ubezp;
-----------------------------------------
END GENERATORY_PKG;
/