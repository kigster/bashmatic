-- vim: ft=sql
select pid, client_addr || ':' || client_port as Client, 
       substring(state for 10) as State, 
       now() - query_start as Duration, 
       substring(query for QUERY_WIDTH) as Query 
from pg_stat_activity 
where state != 'idle' 
order by Duration desc
