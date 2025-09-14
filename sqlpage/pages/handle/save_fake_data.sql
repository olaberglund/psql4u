select 'cookie' as component, 'show_alert' as name, jsonb_build_object('name', 'schema_saved')::text as value;

update schema_definition
set fake_data = :fake_data::text
where id = :schema_id::int
returning 'redirect' as component, '../manage_fake_data.sql?schema_id=' || :schema_id::text as link;

select 'cookie' as component, 'show_alert' as name, jsonb_build_object('name', 'schema_save_error')::text as value;
select 'redirect' as component, '../index.sql' as link;
