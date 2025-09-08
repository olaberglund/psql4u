insert into schema_definition (definition)
values (:Prompt);

select 'redirect' as component, '../schema_definition.sql' as link;
