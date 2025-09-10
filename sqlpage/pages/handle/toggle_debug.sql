set debug_mode = sqlpage.cookie('debug_mode') = 'true';

select 'cookie' as component,
    'debug_mode' as name,
    case when $debug_mode = 'true' then 'false' else 'true' end as value;

select 'redirect' as component, $back_url as link;
