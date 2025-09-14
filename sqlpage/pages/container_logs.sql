select 'dynamic' as component, sqlpage.run_sql('shell.sql', json_build_object('from_url', '/index.sql')) as properties;

select 'text' as component, format('Container logs for "%s"', prompt) as title
from session
join schema_definition on schema_definition.id = session.schema_id
where session.id = $session_id::int;

select '```' || logs_response || '```' as contents_md
from session
where id = $session_id::int;
