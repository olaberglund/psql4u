begin;

-- alter database "ola-olbe" set session_preload_libraries = 'anon';
-- create extension if not exists anon cascade;
-- select anon.init('/Users/ola-olbe/Code/psql4u/postgresql_anonymizer_data_en_US');

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
    container_id text unique
);

create unique index if not exists idx_session_port_listed_unique on session (port, listed) where listed;
create index if not exists idx_session_port_listed on session (port, listed);
create index if not exists idx_session_container_id on session (container_id) where listed;

create table if not exists schema_definition (
    id int generated always as identity primary key,
    session_id int references session(id),
    created_at timestamptz default now(),
    progress text not null check (progress in ('pending', 'in_progress', 'completed', 'failed')) default 'pending',
    definition text not null
);

create index if not exists idx_schema_definition_session_id on schema_definition(session_id);

commit;
