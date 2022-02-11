create schema if not exists CONNECT_TEST;
select *
from SYS.EXA_DBA_TABLES;
drop table CONNECT_TEST."test_table";

-- здесь можно увидеть какие запросы выполняются на стороне экзасола
select sq.SESSION_ID, STMT_ID, COMMAND_NAME, SQL_TEXT, sq.ERROR_TEXT, sq.*
from EXA_STATISTICS.EXA_DBA_AUDIT_SQL sq
join EXA_STATISTICS.EXA_DBA_AUDIT_SESSIONS se
on sq.SESSION_ID = se.SESSION_ID
where OS_USER = 'appuser'
order by START_TIME desc;
