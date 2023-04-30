set serveroutput on
PROMPT Usuwanie &&v_user...
DECLARE
	ilosc number:=0;
BEGIN
	select count(username) into ilosc from all_users where username = UPPER('&&v_user');
	IF ilosc >0 THEN 
		execute immediate 'drop user &&v_user cascade';
		dbms_output.put_line('Uzytkownik &&v_user usuniety ');
	ELSE 
		dbms_output.put_line('Usuwanie uzytkownika przerwane - brak uzytkownika &&v_user');
	END IF;
END;	
/
connect &&v_sys_user/&&v_sys_user_password@&&v_host:&&v_port/&&v_database

PROMPT Tworzenie uzytkownika &&v_user...
	create user &&v_user identified by &&v_password;
	alter user &&v_user quota 100M on USERS;

PROMPT Nadawanie uprawnien...
grant connect, resource to &&v_user;
grant read, write on directory dir_ins to &&v_user;
grant read, write on directory ins_external_table to &&v_user;
grant create any trigger to &&v_user;
grant create any directory to &&v_user;

PROMPT User &&v_user gotowy
