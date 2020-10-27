#!/usr/bin/env bash

figlet -w 160 -f small "Populate Oracle Locally"
liquibase update

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/DERIVEDFACT.csv"' >> .control.ctl
echo '  truncate into table DERIVEDFACT' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( DERIVEDFACTID,' >> .control.ctl
echo '  DERIVEDFACTTRACKINGID,' >> .control.ctl
echo '  DERIVEDFACTTYPEID,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ../../src/db/DERIVEDFACT.csv oracle_container:/ORCL/DERIVEDFACT.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/MEMBERHEALTHSTATE.csv"' >> .control.ctl
echo '  truncate into table MEMBERHEALTHSTATE' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( MEMBERHEALTHSTATESKEY,' >> .control.ctl
echo '  EPISODEID,' >> .control.ctl
echo '  VERSIONNBR,' >> .control.ctl
echo '  STATETYPECD,' >> .control.ctl
echo '  STATECOMPONENTID,' >> .control.ctl
echo '  MEMBERID,' >> .control.ctl
echo '  HEALTHSTATESTATUSCD,' >> .control.ctl
echo '  HEALTHSTATESTATUSCHANGERSNCD,' >> .control.ctl
echo '  HEALTHSTATESTATUSCHANGEDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  HEALTHSTATECHANGEDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  SEVERITYLEVEL,' >> .control.ctl
echo '  COMPLETIONFLG,' >> .control.ctl
echo '  CLINICALREVIEWSTATUSCD,' >> .control.ctl
echo '  CLINICALREVIEWSTATUSDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  LASTEVALUATIONDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  VOIDFLG,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  INSERTEDDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDATEDBY,' >> .control.ctl
echo '  UPDATEDDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  SEVERITYSCORE,' >> .control.ctl
echo '  MASTERSUPPLIERID,' >> .control.ctl
echo '  YEARQTR,' >> .control.ctl
echo '  PDCSCOREPERC)' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ../../src/db/MEMBERHEALTHSTATE.csv oracle_container:/ORCL/MEMBERHEALTHSTATE.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

figlet -w 160 -f small "Check Oracle Locally"
echo 'select * from DERIVEDFACT;' > .command.sql``
echo 'select * from MEMBERHEALTHSTATE;' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql
docker exec oracle_container rm /ORCL/command.sql
rm .control.ctl .command.sql
