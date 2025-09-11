select
    'shell'          as component,
    'PSQL4u'         as title,
    'database-heart' as icon,
    '/'              as link,
    json_build_object(
        'title', 'Create new',
        'icon', 'file-ai',
        'link', 'schema_definition.sql?tab=Schema+definition'
    ) as menu_item,
    json_build_object(
        'title', '',
        'icon', case sqlpage.cookie('debug_mode')
                  when 'true' then'bug'
                  else 'bug-off' end,
        'link', 'handle/toggle_debug.sql?back_url=' || $from_url
    ) as menu_item;
