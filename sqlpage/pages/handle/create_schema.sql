with req(body) as (
  select jsonb_build_object(
      'model', 'gemma3:1b',
      'system', sp.prompt,
      'prompt', :Prompt,
      'stream', false
  )
  from system_prompt sp
  where sp.version = 1
),
net_call  as (
  select request_id
  from req
  cross join net.http_post(
    url => 'http://localhost:11434/api/generate'::text,
    body => req.body
  ) t(request_id)
),
new_schema as (
  insert into schema_definition (prompt, request_id, model)
  select :Prompt, request_id, req.body->>'model'
  from net_call
  cross join req
  returning id
)
update schema_definition
set definition = $api_results
where id = (select id from new_schema);

select 'redirect' as component, '../schema_definition.sql' as link;
