with session_container as (
  select create_response->>'Id' as container_id
  from session
  where id = $session_id::int
),
net_req as (
    select
      net.http_delete(
            url => format('http://localhost:2375/containers/%s?force=true'::text, container_id)
      )
      as request_id
    from session_container
)
update session
set stop_request_id = request_id
from net_req
where id = $session_id::int
returning 'redirect' as component, '../index.sql' as link;

select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'session_unknown', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' as link;
