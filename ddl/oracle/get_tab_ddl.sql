SET long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on

BEGIN
   -- DDL extraction options
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR',        true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY',               true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', true);

   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES',   false);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'STORAGE',              false);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PARTITIONING',         false);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'REF_CONSTRAINTS',      false);
END;
/

-- Basic tab DDL extraction: SELECT dbms_metadata.get_ddl ('TABLE', table_name, owner)

-- "replace" here removes quotes to make tablenames case insensitive
SELECT replace(dbms_metadata.get_ddl ('TABLE', table_name, owner), '"')
  FROM all_tables
 WHERE owner      = upper('&1')
   AND table_name = decode(UPPER('&2'), 'ALL', table_name, upper('&2'));

set pagesize 14 linesize 100 feedback on verify on
