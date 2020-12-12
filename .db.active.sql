-- vim: ft=sql
select pid,
       rpad(coalesce(application_name, 'app'), 7) as app,
       rpad(coalesce(backend_type, 'bcknd'), 15) as backand_type,
       to_char((now() + interval '0.0001 sec' - query_start)::interval, 'HH24:MM:SS.ms') as duration,
       rpad(regexp_replace(query, E'[\\n\\r +]+', ' ', 'g'), QUERY_WIDTH) as Query
from pg_stat_activity
where state != 'idle'
order by duration desc
