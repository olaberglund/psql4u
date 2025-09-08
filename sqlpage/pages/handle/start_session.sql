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
returning 'redirect' as component, '../index.sql' as link;


select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'session_unknown', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' as link;
