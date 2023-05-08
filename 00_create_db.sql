------ ustawienia bazy start ---------------
define v_host = localhost
define v_port = 1521
define v_database = xepdb3
define v_sys_user = system
define v_sys_user_password = sys1
define v_user = ins
define v_password = ins
define v_tablespace = USERS
define v_directory_ext = c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\external_tables\
define v_directory_dp = c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\datapump\
define ilosc_agentow_hurt = 10
define ilosc_polis_hurt = 5

------ ustawienia bazy koniec ---------------

SET FLUSH ON
SET VERIFY OFF
SET FEEDBACK OFF
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

-- tworzenie widoków
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_views.sql"

-- tworzenie widoków zmaterializowanych
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_materialized_views.sql"

-- do każdej hurtowo wprowadzanej polisy generowana jest losowa ilosc powiazanych z nia osob:
-- jako 1 jako ubezpieczajacy + 1-4 jako ubezpieczony

-- wypełnianie tabel danymi
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\populate_db.sql"

-- tworzenie jobow
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_jobs.sql"

-- tworzenie indexow
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_indexes.sql"

--zebranie statystyk na starcie
@"c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\create_stats.sql"
SET FEEDBACK ON
PROMPT Instalacja zakonczona.