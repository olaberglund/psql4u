with available_port as (
  select port from allowed_port
  where port not in (
      select port from session where listed
  )
  limit 1
)
insert into session (port, schema_id)
select port, $new_session_id::int from available_port
returning 'redirect' as component, '../index.sql' as link;

select 'cookie' as component, 'show_alert' as name, jsonb_build_object('name', 'ports_busy')::text as value;

select 'redirect' as component, '../index.sql' as link;
