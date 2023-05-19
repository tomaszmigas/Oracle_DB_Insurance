set serveroutput on
PROMPT Tworzenie Job Job_Stat...
begin
dbms_scheduler.create_program (
    program_name=>'prog_stat',
    program_type=>'PLSQL_BLOCK',
    program_action=>'
    DECLARE
        v_ilosc_p number;
        v_ilosc_k number;
        v_ilosc_s number;
    BEGIN
        dbms_stats.gather_table_stats(ownname=>''&&v_user'',tabname=>''polisy'',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>''&&v_user'',tabname=>''kontrahenci'',cascade=>true);
        dbms_stats.gather_table_stats(ownname=>''&&v_user'',tabname=>''szkody'',cascade=>true);
        SELECT num_rows into v_ilosc_p FROM user_tab_statistics where table_name = ''POLISY'' AND PARTITION_NAME IS NULL;
        SELECT num_rows into v_ilosc_k FROM user_tab_statistics where table_name = ''KONTRAHENCI'' AND PARTITION_NAME IS NULL;
        SELECT num_rows into v_ilosc_s FROM user_tab_statistics where table_name = ''SZKODY'' AND PARTITION_NAME IS NULL;
        INSERT into stat_info values (''Aktualizacja : '' || to_char(current_timestamp,''YYYY-MM-DD HH24:MI:SS''), v_ilosc_p,v_ilosc_k,v_ilosc_s);
    END;
    ',
    enabled=>true
);

dbms_scheduler.create_schedule(
    schedule_name=>'sched_stat',
    start_date=>current_timestamp,
--    end_date=>current_timestamp + INTERVAL '1' HOUR,
--      repeat_interval=>'freq=secondly;interval=5'
      repeat_interval=>'freq=daily;interval=1;byhour=0;byminute=5;bysecond=10'
);

dbms_scheduler.create_job (
    job_name=>'job_stat',
    program_name=>'prog_stat',  
    schedule_name=>'sched_stat',
    enabled=>TRUE
);
end;
/

