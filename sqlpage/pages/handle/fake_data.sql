with req(body) as (
  select jsonb_build_object(
      'model', 'gemma3:1b',
      'system', pg_read_file('../../../system_prompt_fake_data.txt'),
      'prompt', definition,
      'stream', false
  )
  from schema_definition
  where id = :fake_schema_id::int
),
net_call  as (
  select request_id
  from req
  cross join net.http_post(
    url => 'http://localhost:11434/api/generate'::text,
    body => req.body,
    timeout_milliseconds => 30000
  ) t(request_id)
)
update schema_definition
set request_id = net_call.request_id
from net_call
where schema_definition.id = :fake_schema_id::int;

select 'redirect' as component, '../schema_definition.sql?tab=Fake+data' as link;
