with available_port as (
  select port from allowed_port
  where port not in (
      select port from session where listed
  )
  limit 1
)
insert into session (port)
select port from available_port
returning 'redirect' as component, '../index.sql?created' as link;

select 'redirect' as component, '../index.sql?ports_busy' as link;
