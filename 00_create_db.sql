------ ustawienia bazy start ---------------
define v_host = localhost
define v_port = 1521
define v_database = xepdb3
define v_sys_user = system
define v_sys_user_password = sys1
define v_user = ins
define v_password = ins
define v_tablespace = USERS
define v_install_directory = c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance

define v_directory_ext = &&v_install_directory.\external_tables\
define v_directory_dp =  &&v_install_directory.\datapump\

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
@"&&v_install_directory.\create_user.sql"

-- tworzenie tabel i relacji
PROMPT Logownie jako &&v_user...
connect &&v_user/&&v_password@&&v_host:&&v_port/&&v_database
@"&&v_install_directory.\create_tables.sql"

-- tworzenie tabel zewnetrznch i tabel z imionami i nazwiskami
@"&&v_install_directory.\create_external_tables.sql"

-- tworzenie triggerów
@"&&v_install_directory.\create_triggers.sql"

-- tworzenie pakietu agenci_pkg
@"&&v_install_directory.\create_package_agents.sql"

-- tworzenie pakietu polisy_pkg
@"&&v_install_directory.\create_package_policies.sql"

-- tworzenie pakietu osoby_pkg
@"&&v_install_directory.\create_package_persons.sql"

-- tworzenie pakietu generatory_pkg
@"&&v_install_directory.\create_package_generators.sql"

-- tworzenie widoków
@"&&v_install_directory.\create_views.sql"

-- tworzenie widoków zmaterializowanych
@"&&v_install_directory.\create_materialized_views.sql"

-- do każdej hurtowo wprowadzanej polisy generowana jest losowa ilosc powiazanych z nia osob:
-- jako 1 jako ubezpieczajacy + 1-4 jako ubezpieczony

-- wypełnianie tabel danymi
@"&&v_install_directory.\populate_db.sql"

-- tworzenie jobow
@"&&v_install_directory.\create_jobs.sql"

-- tworzenie indexow
@"&&v_install_directory.\create_indexes.sql"

--zebranie statystyk na starcie
@"&&v_install_directory.\create_stats.sql"

SET FEEDBACK ON
PROMPT Instalacja zakonczona.