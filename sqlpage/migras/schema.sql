begin;

-- alter database postgres set session_preload_libraries = 'anon';
-- create extension if not exists anon cascade;
-- select anon.init('/Users/ola-olbe/Code/psql4u/postgresql_anonymizer_data_en_US');
 
-- drop schema public cascade;
-- create schema public;

create extension if not exists pg_net;

create table if not exists allowed_port (
  port int primary key
);

insert into allowed_port
select p from generate_series(5420, 5425) g(p)
on conflict do nothing;

create table if not exists schema_definition (
    id int generated always as identity primary key,
    definition_request_id int not null,
    fake_data_request_id int,
    created_at timestamptz default now(),
    prompt text not null,
    model text not null,
    definition text,
    fake_data text,

    definition_response jsonb,
    fake_data_response jsonb
);


create table if not exists session (
    id int generated always as identity primary key,
    port int not null references allowed_port(port),
    created_at timestamptz default now(),
    schema_id int not null references schema_definition(id),

    create_request_id int,
    start_request_id int,
    stop_request_id int,

    temp_file text,

    create_response jsonb,
    start_response jsonb,
    stop_response jsonb,
    logs_response text
);

create or replace view active_session as (
  select id, port, create_response
  from session
  -- a session is active if it has not been successfully stopped,
  -- or didn't exist when attempting to stop it.
  -- If stop_response is null, there's been no attempt to stop it.
  where coalesce(stop_response->>'status_code' not in ('204', '404'), true)
);

drop index if exists idx_session_port_active_unique;
create unique index if not exists idx_session_port_active_unique on session (port)
    where coalesce(stop_response->>'status_code' not in ('204', '404'), true);

create index if not exists idx_session_container_id on session ((start_response->>'container_id'));

create or replace function trig_net_response_session()
returns trigger as $$
begin
    update session
    set create_response = coalesce(new.content::jsonb, '{}'::jsonb) || jsonb_build_object('status_code', new.status_code)
    where create_request_id = new.id;

    update session
    set start_response = coalesce(new.content::jsonb, '{}'::jsonb) || jsonb_build_object('status_code', new.status_code)
    where start_request_id = new.id;

    update session
    set stop_response = coalesce(new.content::jsonb, '{}'::jsonb) || jsonb_build_object('status_code', new.status_code)
    where stop_request_id = new.id;

    return new;
end;
$$ language plpgsql;


create or replace trigger trg_net_response_session
after insert on net._http_response
for each row
execute function trig_net_response_session();

create or replace function trig_net_response_schema_definition()
returns trigger as $$
begin
    update schema_definition
    set definition_response = new.content::jsonb || jsonb_build_object('status_code', new.status_code),
        definition = trim(regexp_replace((new.content::jsonb)->>'response', '```sql|```', '', 'g'))
    where definition_request_id = new.id;

    update schema_definition
    set fake_data_response = new.content::jsonb || jsonb_build_object('status_code', new.status_code),
        fake_data = trim(regexp_replace((new.content::jsonb)->>'response', '```sql|```', '', 'g'))
    where fake_data_request_id = new.id;

    return new;
end;
$$ language plpgsql;

create or replace function write_schema_seed_file(schema_id int)
returns text strict as $$
declare
  fname text := '/tmp/psql4u_schema_' || md5(random()::text);
begin
    execute format($cmd$
      copy (
          select replace(line, E'\r', '')
          from schema_definition
          cross join string_to_table(definition || coalesce(fake_data, ''), E'\n') s(line)
          where id = %s
      ) to %L
      $cmd$, schema_id, fname);

    return fname;
end;
$$ language plpgsql;


create or replace trigger trg_net_response_schema_definition
after insert on net._http_response
for each row
execute function trig_net_response_schema_definition();

commit;
