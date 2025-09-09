with net_call  as (
  select request_id
  from system_prompt
  cross join net.http_post(
    url => 'http://localhost:11434/api/generate'::text,
    body => jsonb_build_object(
        'model', 'gemma3:1b',
        'system', system_prompt.prompt,
        'prompt', :Prompt,
        'stream', false
    )
  ) t(request_id)
  where version = 1
),
new_schema as (
  insert into schema_definition (prompt, request_id)
  select :Prompt, request_id
  from net_call
  returning id
)
update schema_definition
set definition = $api_results
where id = (select id from new_schema);

select 'redirect' as component, '../schema_definition.sql' as link;
