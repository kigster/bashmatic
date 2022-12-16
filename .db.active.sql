-- vim: ft=sql
-- /* db.top.active.queries */
select
  pid,
  rpad(coalesce(application_name, 'app'), 7) as app,
  rpad(coalesce(state, 'state'), 7) as state,
  to_char((now() + interval '0.0001 sec' - query_start)::interval, 'HH24:MM:SS.ms') as duration,
  rpad(regexp_replace(query, E'[\\n\\r +]+', ' ', 'g'), QUERY_WIDTH) as Query
from pg_stat_activity
where state not like '%QUERY_FILTER_OUT%' and query not like '%db.top.active.queries%'
order by duration desc;
