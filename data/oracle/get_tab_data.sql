set echo      off
set feed      off
set verify    off
set head      off
set headsep   off 
set colsep    '|'

set pagesize  0
set linesize  6000
set trimspool on
set trimout   on
set trim on

alter session set nls_date_format      = 'YYYY-MM-DD HH24:MI:SS'  ;
alter session set nls_timestamp_format = 'YYYY-MM-DD HH24:MI:SS.FF' ;



set termout off 

-- assign spool
-- spool file format: schema.table.csv
column spfile new_value spfile noprint
select '&&1'||'.'||'&&2'||'.csv' spfile from dual;

spool &spfile 
    alter session set current_schema=&&1;
    select t.*  from  &&2 t;
spool off
