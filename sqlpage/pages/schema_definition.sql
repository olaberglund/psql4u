set show_alert = sqlpage.cookie('show_alert')::jsonb;
select 'cookie' as component, 'show_alert' as name, true as remove;

select 'alert'     as component,
  'Schema created' as title,
  'green'          as color,
  'check'          as icon,
  true             as dismissible
where $show_alert::jsonb->>'name' = 'schema_created';

select 'dynamic' as component, sqlpage.run_sql('shell.sql') as properties;

select
    'form'          as component,
    'Schema Prompt' as title,
    'Generate'      as validate,
    'handle/create_schema.sql' as action;
select
    'Prompt'   as name,
    'textarea' as type;

select 'foldable' as component;
select case when definition is null then 'Generating: ' || prompt else prompt end as title, definition as description_md
from schema_definition;
