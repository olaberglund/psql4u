set container_id =  (
  select create_response->>'Id' as container_id
  from session
  where id = $session_id::int
);

select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'session_unknown', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' as link
where $container_id not in (select create_response->>'Id' from active_session);

set logs = sqlpage.exec('docker', 'logs', $container_id);

update session
set logs_response = regexp_replace($logs, '.*?(\n/usr/local/bin/docker-entrypoint.sh).*', '\1', 's')
where id = $session_id::int and $logs is not null
returning 'redirect' as component, '../container_logs.sql?session_id=' || $session_id as link;

select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'session_unknown', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' || $session_id as link;
