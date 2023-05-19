set serveroutput on
PROMPT Generowanie statystyk...
begin
	dbms_stats.gather_table_stats(ownname=>'&&v_user',tabname=>'polisy',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>'&&v_user',tabname=>'kontrahenci',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>'&&v_user',tabname=>'szkody',cascade=>true);
END;
/
