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
  'alert'                      as component,
  'DEBUG'                      as title,
  'blue'                       as color,
  'info-circle'                as icon,
  true                         as dismissible,
  $show_alert::jsonb->>'value' as description
where $show_alert::jsonb->>'name' = 'debug';

select
  'alert'           as component,
  'Unknown session' as title,
  'red'             as color,
  'alert-circle'    as icon,
  true              as dismissible,
  'Could not find session with id: ' || ($show_alert::jsonb->>'session_id') as description
where $show_alert::jsonb->>'name' = 'session_unknown';

select 'form' as component, 'Create' as validate, 'handle/create_session.sql' as action;

select 'select'           as type,
  'new_session_schema_id' as name,
  'Create new session'    as label,
  'Select a schema...'    as empty_option,
  true                    as required,
  jsonb_agg(
    jsonb_build_object(
  'label', prompt || case when fake_data is null then '' else ' (fake data)' end,
      'value', id
    ) order by prompt
  ) as options
from schema_definition;

select 'list' as component,
  format('Sessions: %s / %s',
      (select count(*) from active_session),
      (select count(*) from allowed_port)
  ) as title;

select 'database' as icon,
  case
      when stop_response->>'status_code' = '204' then 'black'
      when start_response->>'status_code' = '204' then 'green'
      when create_response->>'status_code' = '201' then 'red'
      else 'gray'
  end as color,
  case when create_response->>'Id' is not null and start_response is null then format('handle/start_session.sql?session_id=%s', session.id) end       as link,
  format('edit_session?session_id=%s', session.id)                                                                         as edit_link,
  format('handle/stop_session.sql?session_id=%s', session.id)                                                              as delete_link,
  format($s$%s %s @ `Port %s` | %s ago $s$,
      case when stop_request_id is not null and stop_response is null then 'Stopping: '
           when start_request_id is not null and start_response is null then 'Starting: '
           when create_request_id is not null and create_response is null then 'Creating: '
           else ''
      end,
      sd.prompt,
      port,
      to_char(age(now(), session.created_at),
      'MI"m" SS"s"')) as description_md
from session
join schema_definition sd on sd.id = session.schema_id
order by session.created_at desc;
