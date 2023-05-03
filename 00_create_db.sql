------ ustawienia bazy start ---------------
define v_host = localhost
define v_port = 1521
define v_database = xepdb3
define v_sys_user = system
define v_sys_user_password = sys1
define v_user = ins4
define v_password = ins4
define ilosc_agentow_hurt = 4
define ilosc_polis_hurt = 5

------ ustawienia bazy koniec ---------------

SET FLUSH ON
SET VERIFY OFF
--HOST chcp 852
--exit

-- tworzenie uzytkownika &&v_user
PROMPT laczenie jako system...
connect &&v_sys_user/&&v_sys_user_password@&&v_host:&&v_port/&&v_database
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_user.sql"

-- tworzenie tabel i relacji
PROMPT Logownie jako &&v_user...
connect &&v_user/&&v_password@&&v_host:&&v_port/&&v_database
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_tables.sql"

-- tworzenie tabel zewnetrznch i tabel z imionami i nazwiskami
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_external_tables.sql"

-- tworzenie triggerów
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_triggers.sql"

-- tworzenie pakietu agenci_pkg
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_package_agents.sql"

-- tworzenie pakietu polisy_pkg
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_package_policies.sql"

-- tworzenie pakietu osoby_pkg
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_package_persons.sql"

-- tworzenie pakietu generatory_pkg
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_package_generators.sql"

-- do każdej hurtowo wprowadzanej polisy generowana jest losowa ilosc powiazanych z nia osob:
-- jako 1 jako ubezpieczajacy + 1-4 jako ubezpieczony

-- wypełnianie tabel danymi
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\populate_db.sql"

PROMPT Instalacja zakonczona.





