#!/usr/bin/env bash

sleep 2m
figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 200 -f small "Populate Oracle AWS"
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cd /tmp ; java -jar liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@localhost:1521:ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc8.jar" --changeLogFile=changeset.oracle.xml update'

echo 'options  ( skip=1 )' >/tmp/control.ctl
echo 'load data' >>/tmp/control.ctl
echo '  infile "/tmp/DERIVEDFACT.csv"' >>/tmp/control.ctl
echo '  truncate into table DERIVEDFACT' >>/tmp/control.ctl
echo 'fields terminated by ","' >>/tmp/control.ctl
echo '( DERIVEDFACTID,' >>/tmp/control.ctl
echo '  DERIVEDFACTTRACKINGID,' >>/tmp/control.ctl
echo '  DERIVEDFACTTYPEID,' >>/tmp/control.ctl
echo '  INSERTEDBY,' >>/tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  UPDTDBY) ' >>/tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo 'options  ( skip=1 )' >/tmp/control.ctl
echo 'load data' >>/tmp/control.ctl
echo '  infile "/tmp/MEMBERHEALTHSTATE.csv"' >>/tmp/control.ctl
echo '  truncate into table MEMBERHEALTHSTATE' >>/tmp/control.ctl
echo 'fields terminated by ","' >>/tmp/control.ctl
echo '( MEMBERHEALTHSTATESKEY,' >>/tmp/control.ctl
echo '  EPISODEID,' >>/tmp/control.ctl
echo '  VERSIONNBR,' >>/tmp/control.ctl
echo '  STATETYPECD,' >>/tmp/control.ctl
echo '  STATECOMPONENTID,' >>/tmp/control.ctl
echo '  MEMBERID,' >>/tmp/control.ctl
echo '  HEALTHSTATESTATUSCD,' >>/tmp/control.ctl
echo '  HEALTHSTATESTATUSCHANGERSNCD,' >>/tmp/control.ctl
echo '  HEALTHSTATESTATUSCHANGEDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  HEALTHSTATECHANGEDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  SEVERITYLEVEL,' >>/tmp/control.ctl
echo '  COMPLETIONFLG,' >>/tmp/control.ctl
echo '  CLINICALREVIEWSTATUSCD,' >>/tmp/control.ctl
echo '  CLINICALREVIEWSTATUSDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  LASTEVALUATIONDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  VOIDFLG,' >>/tmp/control.ctl
echo '  INSERTEDBY,' >>/tmp/control.ctl
echo '  INSERTEDDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  UPDATEDBY,' >>/tmp/control.ctl
echo '  UPDATEDDT DATE "YYYY-MM-DD",' >>/tmp/control.ctl
echo '  SEVERITYSCORE,' >>/tmp/control.ctl
echo '  MASTERSUPPLIERID,' >>/tmp/control.ctl
echo '  YEARQTR,' >>/tmp/control.ctl
echo '  PDCSCOREPERC)' >>/tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

figlet -w 200 -f small "Check Oracle AWS"
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; echo "select * from DERIVEDFACT;" | sqlplus system/OraPasswd1@localhost:1521/ORCL'
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; echo "select * from MEMBERHEALTHSTATE;" | sqlplus system/OraPasswd1@localhost:1521/ORCL'
