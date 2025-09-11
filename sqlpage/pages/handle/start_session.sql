set debug_mode = sqlpage.cookie('debug_mode');

set mport_mapping = (
  select port || ':5432'
  from session
  where id = $session_id::int and listed and container_id is null
);

set tmpfile = regexp_replace(sqlpage.exec('mktemp'), '\s', '');
set def = (
    select trim(regexp_replace(definition, '```sql|```', '', 'g'))
    from schema_definition
    where id = (select schema_id from session where id = $session_id::int and listed)
);
set f_data = (
    select coalesce(trim(regexp_replace(fake_data, '```sql|```', '', 'g')), '')
    from schema_definition
    where id = (select schema_id from session where id = $session_id::int and listed)
);

set _ = sqlpage.exec('sh', '-c', 'echo "$1" > "$2"', '', $def, $tmpfile);
set _ = sqlpage.exec('sh', '-c', 'echo "$1" >> "$2"', '', $f_data, $tmpfile);

set volume = (select format('%s:/docker-entrypoint-initdb.d/init.sql:ro', $tmpfile));

select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'debug', 'value', 'docker run --rm -e POSTGRES_PASSWORD=hunter2 -p ' || $mport_mapping || ' -v ' || $volume || ' postgres')::text as value
where $debug_mode = 'true';
select 'redirect' as component, '../index.sql' as link
where $debug_mode = 'true';

-- -- TODO : use docker api
set mcontainer_id = (
    select sqlpage.exec(
        'docker', 'run', '--rm',
        '-e', 'POSTGRES_PASSWORD=hunter2',
        '-p', $mport_mapping,
        '-v', $volume,
        '-d', 'postgres'
    )
  where $mport_mapping is not null
);

--set _ = (select sqlpage.exec('rm', $tmpfile));

update session
set container_id = $mcontainer_id, temp_file = $tmpfile
where id = $session_id::int and listed and container_id is null
returning 'redirect' as component, '../index.sql' as link;


select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'session_unknown', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' as link;
