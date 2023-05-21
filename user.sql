--directory do utworzenia przez usera z uprawnieniami create any directory:
CREATE OR REPLACE DIRECTORY ins_external_table AS 'ścieżka do katalogu external_table';
CREATE OR REPLACE DIRECTORY ins_datapump AS 'ścieżka do katalogu datapump';

drop user ins cascade;

create user ins identified by ins;
alter user ins quota 4G on users;
grant connect, resource to ins;
grant read, write on directory ins_external_table to ins;
grant read, write on directory ins_datapump to ins;

grant create view to ins;
grant create materialized view to ins;
grant create trigger to ins;
GRANT CREATE JOB TO ins;
