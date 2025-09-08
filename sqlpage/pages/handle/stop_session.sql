set msession_id = (
    select id from session
    where id = $session_id::int and listed
);


-- unkown session
select 'cookie' as component, 'show_alert' as name,
  jsonb_build_object('name', 'unknown_session', 'session_id', $session_id)::text as value;

select 'redirect' as component, '../index.sql' as link
where $msession_id is null;

-- stopped session
update session
set listed = false
where id = $msession_id::int and container_id is null
returning 'redirect' as component, '../index.sql' as link;

-- started session
set mcontainer_id = (
    select container_id
    from session
    where id = $msession_id::int and container_id is not null
);

update session
set listed = false
where id = $msession_id::int
returning sqlpage.exec('docker', 'stop', $mcontainer_id), 'redirect' as component, '../index.sql' as link;
