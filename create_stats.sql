set serveroutput on
PROMPT Generowanie statystyk...
begin
	dbms_stats.gather_table_stats(ownname=>'INS',tabname=>'polisy',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>'INS',tabname=>'kontrahenci',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>'INS',tabname=>'szkody',cascade=>true);
END;
/
