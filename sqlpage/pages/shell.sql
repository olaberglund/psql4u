select
    'shell'          as component,
    'PSQL4u'         as title,
    'database-heart' as icon,
    '/'              as link,
    json_build_object(
        'title', 'Create new',
        'icon', 'file-ai',
        'link', 'schema_definition.sql'
    ) as menu_item,
    json_build_object(
        'title', 'Browse',
        'icon', 'book',
        'link', 'browser_schem as .sql'
    ) as menu_item;

