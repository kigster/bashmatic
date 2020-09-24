-- vim: ft=sql
select pid, client_addr || ':' || client_port as Client, 
       substring(state for 10) as State, 
       now() - query_start as Duration, 
       regexp_replace(substring(query, 0, QUERY_WIDTH), E'[\\n\\r +]+', ' ', 'g' ) as Query
from pg_stat_activity 
where state != 'idle' 
order by Duration desc
