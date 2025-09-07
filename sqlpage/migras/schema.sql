begin;

drop schema public cascade;
create schema public;

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

commit;
