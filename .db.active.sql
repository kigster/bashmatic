-- vim: ft=sql
select pid,
       substring(application_name for 10) as app_name,
       substring(backend_type for 16) as bcknd_type,
       substring(state for 10) as state,
       wait_event_type || '/' || wait_event as wait,
       now() - query_start as duration,
       regexp_replace(substring(query, 0, QUERY_WIDTH), E'[\\n\\r +]+', ' ', 'g') as Query
from pg_stat_activity
where state != 'idle'
order by Duration desc