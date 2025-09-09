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
    container_id text unique
);

create unique index if not exists idx_session_port_listed_unique on session (port, listed) where listed;
create index if not exists idx_session_port_listed on session (port, listed);
create index if not exists idx_session_container_id on session (container_id) where listed;

create table if not exists schema_definition (
    id int generated always as identity primary key,
    session_id int references session(id),
    request_id int not null,
    created_at timestamptz default now(),
    prompt text not null,
    definition text,
    response jsonb
);

create index if not exists idx_schema_definition_session_id on schema_definition(session_id);

create or replace function trig_net_response()
returns trigger as $$
begin
    update schema_definition sd
    set response = content::jsonb,
        definition = (content::jsonb)->>'response'
    from net._http_response nhp
    where sd.request_id = nhp.id;

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


CREATE TABLE bananas ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, variety TEXT, date_harvest TEXT, location TEXT, quantity INT ); CREATE TABLE fruit_suppliers ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT, address TEXT, city TEXT, country TEXT ); CREATE TABLE fruit_markets ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT, location TEXT, country TEXT ); CREATE TABLE banana_sales ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, banana_id INT REFERENCES bananas(id), supplier_id INT REFERENCES fruit_suppliers(id), date_sold TEXT, revenue NUMERIC ); CREATE TABLE fruit_suppliers_categories ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT, category TEXT ); CREATE TABLE fruit_markets_regions ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT, region TEXT ); CREATE TABLE banana_sales_details ( id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, banana_id INT, quantity_sold INT, sales_date TEXT, revenue NUMERIC );
