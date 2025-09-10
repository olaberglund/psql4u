set show_alert = sqlpage.cookie('show_alert');
select 'cookie' as component, 'show_alert' as name, true as remove;

select 'dynamic' as component, sqlpage.run_sql('shell.sql', json_build_object('from_url', '/index.sql')) as properties;

select
  'alert'        as component,
  'Busy'         as title,
  'red'          as color,
  'alert-circle' as icon,
  true           as dismissible,
  'All ports are busy, please try again later.' as description
where $show_alert::jsonb->>'name' = 'ports_busy';

select
  'alert'           as component,
  'Unknown session' as title,
  'red'             as color,
  'alert-circle'    as icon,
  true              as dismissible,
  'Could not find session with id: ' || ($show_alert::jsonb->>'session_id') as description
where $show_alert::jsonb->>'name' = 'session_unknown';

select 'form' as component, 'Create' as validate, 'handle/create_session.sql' as action;

select 'select'         as type,
  'new_session_id'      as name,
  'Create new session'  as label,
  'Select a schema...'  as empty_option,
  true                  as required,
  jsonb_agg(
    jsonb_build_object('label', prompt, 'value', id)
  ) as options
from schema_definition;

select 'list' as component,
  format('Sessions: %s / %s',
      (select count(*) from session where listed),
      (select count(*) from allowed_port)
  ) as title;

select 'database'                                                                                             as icon,
  case when container_id is null then 'red' else 'green' end                                                  as color,
  case when container_id is not null then null else format('handle/start_session.sql?session_id=%s', id) end  as link,
  format('edit_session?session_id=%s', id)                                                                    as edit_link,
  format('handle/stop_session.sql?session_id=%s', id)                                                         as delete_link,
  format($s$**ID: %s** | `Port %s` | %s ago$s$, id, port, to_char(age(now(), created_at), 'MI"m" SS"s"'))     as description_md
from session
where listed order by created_at desc;
