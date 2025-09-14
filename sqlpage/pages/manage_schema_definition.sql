set show_alert = sqlpage.cookie('show_alert')::jsonb;
select 'cookie' as component, 'show_alert' as name, true as remove;

select 'dynamic' as component, sqlpage.run_sql('shell.sql', json_build_object('from_url', '/schema_definition.sql')) as properties;

select 'alert'     as component,
  'Schema saved'   as title,
  'green'          as color,
  'check'          as icon,
  true             as dismissible
where $show_alert::jsonb->>'name' = 'schema_saved';

select 'alert'           as component,
  'Something went wrong' as title,
  'red'                  as color,
  'alert-circle'         as icon,
  true                   as dismissible
where $show_alert::jsonb->>'name' = 'schema_save_error';

select 'form' as component, 'Save' as validate, 'handle/save_schema_definition.sql' as action;

select 'hidden' as type, 'schema_id' as name, $schema_id::int as value;
select
  'Definition' as label,
  'definition' as name,
  'textarea' as type,
  definition as value,
  cardinality(string_to_array(definition, E'\n')) as rows
from schema_definition
where id = $schema_id::int;
