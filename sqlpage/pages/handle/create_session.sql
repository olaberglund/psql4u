with available_port as (
  select port from allowed_port
  where port not in (
      select port from active_session
  )
  limit 1
),
net_req as (
    select case when exists (select 1 from available_port)
      then net.http_post(
          url => 'http://localhost:2375/containers/create'::text,
          body => jsonb_build_object(
              'Image', 'postgres',
              'Env', array['POSTGRES_PASSWORD=hunter2'],
              'HostConfig', json_build_object(
                  'AutoRemove', true,
                  'Binds', array[
                    format('%s:/docker-entrypoint-initdb.d/init.sql:ro',
                      write_schema_seed_file($new_session_schema_id::int))
                  ],
                  'PortBindings', jsonb_build_object(
                      '5432/tcp', array[
                          jsonb_build_object('HostPort', 
                              (select port::text from available_port)
                          )
                      ]))))
      end as request_id
)
insert into session (port, schema_id, create_request_id)
select port, $new_session_schema_id::int, request_id
from available_port
cross join net_req
returning 'redirect' as component, '../index.sql' as link;

select 'cookie' as component, 'show_alert' as name, jsonb_build_object('name', 'ports_busy')::text as value;

select 'redirect' as component, '../index.sql' as link;
