PROMPT Tworzenie triggera Schema Logon Check...
create or replace trigger trig_schema_logon_check
AFTER LOGON ON &&v_user..SCHEMA
BEGIN
    INSERT INTO info_log ("EVENT","DATA","TIME","USER",DB_NAME,"SESSION_ID",IP_ADDRESS,NETWORK_PROTOCOL)
    select 
    'LOGON'
    ,sysdate
    ,TO_CHAR(systimestamp,'HH24:MI:SS')
    ,SYS_CONTEXT('USERENV','SESSION_USER')
    ,SYS_CONTEXT('USERENV','DB_NAME')
    ,SYS_CONTEXT('USERENV','SID')
    ,SYS_CONTEXT('USERENV','IP_ADDRESS')
    ,SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')
    from dual;
END trig_schema_logon_check;
/

PROMPT Tworzenie triggera Schema Logoff Check...
create or replace trigger trig_schema_logoff_check
BEFORE LOGOFF ON &&v_user..SCHEMA
BEGIN
    INSERT INTO info_log ("EVENT","DATA","TIME","USER",DB_NAME,"SESSION_ID",IP_ADDRESS,NETWORK_PROTOCOL)
    select 
    'LOGOFF'
    ,sysdate
    ,TO_CHAR(systimestamp,'HH24:MI:SS')
    ,SYS_CONTEXT('USERENV','SESSION_USER')
    ,SYS_CONTEXT('USERENV','DB_NAME')
    ,SYS_CONTEXT('USERENV','SID')
    ,SYS_CONTEXT('USERENV','IP_ADDRESS')
    ,SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')
    from dual;
END trig_schema_logoff_check;
/

create or replace TRIGGER CHANGE_DATE_FORMAT
AFTER LOGON ON &&v_user..SCHEMA
begin
	DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT','"YYYY-MM-DD"');
end CHANGE_DATE_FORMAT;
/

PROMPT Tworzenie triggera Kontrahenci_Check...
create or replace trigger trig_kontrahenci_check BEFORE INSERT ON szkody FOR EACH ROW
DECLARE
	v_check number;
    e_brak_wpisu exception;
    PRAGMA EXCEPTION_INIT (e_brak_wpisu,-20998);
BEGIN
	SELECT COUNT(nr_polisy) into v_check from kontrahenci where nr_polisy = :NEW.nr_polisy and id_osoby = :NEW.id_osoby;
	IF v_check = 0 THEN
            RAISE_APPLICATION_ERROR(-20998,'Trig Exception - brak odpowiedniego wpisu w tabeli kontrahenci');
	END IF;
EXCEPTION
    WHEN e_brak_wpisu THEN
        dbms_output.put_line(sqlerrm);
        RAISE;
	
END trig_kontrahenci_check;
/