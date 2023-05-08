set serveroutput on
PROMPT Tworzenie indexow...

create index polisy_data_od_idx on polisy(data_od);
create index polisy_data_do_idx on polisy(data_do);
create index polisy_nr_agenta_idx on polisy(nr_agenta);

create index szkody_wart_wypl_idx on szkody(wartosc_wyplaty);
create index szkody_data_zgloszenia_idx on szkody(data_zgloszenia);

create index kontrahenci_id_osoby_idx on kontrahenci(id_osoby);
create bitmap index kontrahenci_id_roli_idx on kontrahenci(id_roli);
