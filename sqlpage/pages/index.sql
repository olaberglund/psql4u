select 'form' as component, 'Create' as validate, 'handle/create_session.sql' as action;
select 'select' as type,
  'Create new session' as name,
  'Select a schema...' as empty_option,
  true as required,
    '[{"label": "Orange", "value": 0}, {"label": "Apple", "value": 1}, {"label": "Banana", "value": 3}]' as options;

select 'list' as component,
  format('Sessions: %s / %s', (select count(*) from session where listed), (select count(*) from allowed_port)) as title;

select 'database' as icon,
  case when container_id is null then 'red' else 'green' end as color,
  case when container_id is not null then null else format('handle/start_session.sql?session_id=%s', id) end as link,
  format('edit_session?session_id=%s', id) as edit_link,
  format('handle/stop_session.sql?session_id=%s', id) as delete_link,
  format($s$**ID: %s** | `Port %s` | %s ago$s$, id, port, to_char(age(now(), created_at), 'MI"m" SS"s"')) as description_md
from session
where listed order by created_at desc;

select 'alert' as component,
  'New session created' as title,
  'green' as color,
  'check' as icon,
  true as dismissible
where $created is not null;

select 'alert' as component,
  'Started' as title,
  'Started session with id: ' || $started_session as description,
  'green' as color,
  'check' as icon,
  true as dismissible
where $started_session is not null;

select 'alert' as component,
  'Stopped' as title,
  'Stopped session with id: ' || $stopped as description,
  'green' as color,
  'check' as icon,
  true as dismissible
where $stopped is not null;

select 'alert' as component,
  'Busy' as title,
  'All ports are busy, please try again later.' as description,
  'red' as color,
  'alert-circle' as icon,
  true as dismissible
where $ports_busy is not null;

select 'alert' as component,
  'Unknown session' as title,
  'Could not find session with id: ' || $unkown_session as description,
  'red' as color,
  'alert-circle' as icon,
  true as dismissible
where $unkown_session is not null;

