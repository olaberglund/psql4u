with req(body) as (
  select jsonb_build_object(
      'model', 'gemma3:1b',
      'system', pg_read_file('../../../system_prompt.txt'),
      'prompt', :schema_prompt,
      'stream', false
  )
),
net_call as (
  select request_id
  from req
  cross join net.http_post(
    url => 'http://localhost:11434/api/generate'::text,
    body => req.body,
    timeout_milliseconds => 30000
  ) t(request_id)
)
insert into schema_definition (prompt, request_id, model)
select :schema_prompt, request_id, req.body->>'model'
from net_call
cross join req;

select 'redirect' as component, '../schema_definition.sql?tab=Schema+definition' as link;
