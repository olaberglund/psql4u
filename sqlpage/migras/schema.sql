begin;

alter database postgres set session_preload_libraries = 'anon';
create extension if not exists anon cascade;
select anon.init('/Users/ola-olbe/Code/psql4u/postgresql_anonymizer_data_en_US');
create extension if not exists pg_net;

create table if not exists allowed_port (
  port int primary key
);

insert into allowed_port
select p from generate_series(5420, 5425) g(p)
on conflict do nothing;

create table if not exists session (
    id int generated always as identity primary key,
    port int not null references allowed_port(port),
    created_at timestamptz default now(),
    listed bool not null default true,
    schema_id int not null references schema_definition(id),
    temp_file text,
    container_id text unique
);

create unique index if not exists idx_session_port_listed_unique on session (port, listed) where listed;
create index if not exists idx_session_port_listed on session (port, listed);
create index if not exists idx_session_container_id on session (container_id) where listed;

create table if not exists schema_definition (
    id int generated always as identity primary key,
    request_id int not null,
    created_at timestamptz default now(),
    prompt text not null,
    model text not null,
    definition text,
    response jsonb,
);

create or replace function trig_net_response()
returns trigger as $$
begin
    update schema_definition sd
    set response = content::jsonb,
        definition = (new.content::jsonb)->>'response'
    where sd.request_id = new.id;

    -- TODO: use docker api, but im going to end up with a pretty complex state machine
    -- update session s
    -- set response = content::jsonb,
    --     listed =
    --         case
    --           when new.status_code >= 200 then false
    --           else true
    --         end
    -- where s.request_id = new.id;

    return new;
end;
$$ language plpgsql;


create or replace trigger trg_net_response
after insert or update on net._http_response
for each row
execute function trig_net_response();

create table if not exists system_prompt (
    id int generated always as identity primary key,
    version int not null,
    created_at timestamptz default now(),
    prompt text not null unique
);

insert into system_prompt (version, prompt)
select 1, pg_read_file('../../../system_prompt.txt')
on conflict do nothing;

commit;



