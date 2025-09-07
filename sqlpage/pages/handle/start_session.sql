set mport_mapping = (
  select port || ':5432'
  from session
  where id = $session_id::int and listed and container_id is null
);

set mcontainer_id = (
  select sqlpage.exec('docker', 'run', '--rm',  '-e', 'POSTGRES_PASSWORD=hunter2', '-p', $mport_mapping, '-d', 'postgres')
  where $mport_mapping is not null
);

update session
set container_id = $mcontainer_id
where id = $session_id::int and listed and container_id is null
returning 'redirect' as component, '../index.sql?started_session=' || id as link;

select 'redirect' as component, '../index.sql?unkown_session=' || $session_id as link;
