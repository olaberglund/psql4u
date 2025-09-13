set show_alert = sqlpage.cookie('show_alert')::jsonb;
select 'cookie' as component, 'show_alert' as name, true as remove;

select 'alert'     as component,
  'Schema created' as title,
  'green'          as color,
  'check'          as icon,
  true             as dismissible
where $show_alert::jsonb->>'name' = 'schema_created';

select 'dynamic' as component, sqlpage.run_sql('shell.sql', json_build_object('from_url', '/schema_definition.sql?tab=' || $tab)) as properties;

select 'tab' as component;
select 'Schema definition' as title, '?tab=Schema+definition' as link, $tab = 'Schema definition' as active;
select 'Fake data' as title, '?tab=Fake+data' as link, $tab = 'Fake data' as active;

select
    'form'                     as component,
    'Generate'                 as validate,
    'handle/create_schema.sql' as action
where $tab = 'Schema definition';

select
    'schema_prompt'                              as name,
    'Schema prompt'                              as label,
    'textarea'                                   as type,
    'Write a short description of your desired schema...' as placeholder
where $tab = 'Schema definition';

select 'foldable' as component;
select case when definition is null then 'Generating: ' || prompt else prompt end as title, '```sql' || definition || '```' as description_md
from schema_definition
where $tab = 'Schema definition'
order by created_at desc;


select 'form' as component, 'Generate' as validate, 'handle/fake_data.sql' as action
where $tab = 'Fake data';

with opts as (
  select jsonb_agg(
    jsonb_build_object(
      'label', prompt || case when fake_data is null then '' else ' (regenerate)' end,
      'value', id
    )
  ) as options
  from schema_definition
  where definition is not null
)
select 'select'      as type,
  'fake_schema_id'   as name,
  'Fake data'        as label,
  'Fake data for...' as empty_option,
  true               as required,
  (select options from opts) as options
where $tab = 'Fake data';

select 'foldable' as component;
select prompt as title, fake_data as description_md
from schema_definition
where $tab = 'Fake data' and fake_data is not null
order by created_at desc;

