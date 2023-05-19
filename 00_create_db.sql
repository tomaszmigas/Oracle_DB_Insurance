------ ustawienia bazy start ---------------
define v_host = localhost
define v_port = 1521
define v_database = xepdb3
define v_sys_user = system
define v_sys_user_password = sys1
define v_user = ins
define v_password = ins
define v_tablespace = USERS
define v_install_directory = c:\app\Tomek\product\21c\oradata\XE\XEPDB3\insurance\

define v_directory_ext = &&v_install_directory.\external_tables\
define v_directory_dp =  &&v_install_directory.\datapump\

--agenci hurt
define ilosc_agentow_hurt = 200

--polisy hurt
define ilosc_polis_hurt = 10000					-- ilosc polis do utworzenia
define max_osob_na_polisie = 4					-- ile osob moze byc max na 1 polisie
define data_polisy_od = "DATE'1970-01-01'"			-- data początkowa polis
define data_polisy_do = "DATE'&_DATE'"				-- data końcowa polis
define skladka_proc = 2						-- skladka jako % wylosowanej sumy ubezepieczenia
define suma_min = 500						-- minimalna  suma ubezpieczenia na polisach
define suma_max = 100000					-- maksymalna suma ubezpieczenia na polisach
define procent = 100						-- szansa że ubezpieczajacy bedzie tez ubezepieczonym na tej samej polisie

--szkody hurt
define ilosc_szkod_hurt = 500					-- ilosc szkód do utworzenia na dowolnych polisach
define max_szkod_na_polisie = 3					-- max ilość szkód na wylosowanej polisie (jeżeli polisa zostanie wylosowana kilka razy to szkód może być więcej)

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

-- tworzenie pakietu generatory_pkg
@"&&v_install_directory.\create_package_generators.sql"

-- tworzenie pakietu polisy_pkg
@"&&v_install_directory.\create_package_policies.sql"

-- tworzenie pakietu osoby_pkg
@"&&v_install_directory.\create_package_persons.sql"

-- tworzenie pakietu szkody_pkg
@"&&v_install_directory.\create_package_claims.sql"

-- tworzenie widoków
@"&&v_install_directory.\create_views.sql"

-- tworzenie widoków zmaterializowanych
@"&&v_install_directory.\create_materialized_views.sql"

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