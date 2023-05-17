drop user ins cascade;

create user ins identified by ins;
alter user ins quota 400M on users;
grant connect, resource to ins;
grant read, write on directory ins_external_table to ins;
grant read, write on directory ins_datapump to ins;

grant create view to ins;
grant create materialized view to ins;
grant create trigger to ins;
GRANT CREATE JOB TO ins;
