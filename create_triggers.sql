PROMPT Tworzenie triggera 1...

create or replace trigger trig_schema_logon_check
AFTER LOGON ON INS4.SCHEMA
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
PROMPT Tworzenie triggera 2...
create or replace trigger trig_schema_logoff_check
BEFORE LOGOFF ON INS4.SCHEMA
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
AFTER LOGON ON INS4.SCHEMA
begin
	DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT','"YYYY/MM/DD"');
end CHANGE_DATE_FORMAT;
/