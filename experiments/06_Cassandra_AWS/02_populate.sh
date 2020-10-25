#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 200 -f small "Populate Cassandra on AWS"

figlet -w 200 -f small "Create Cassandra Database (Keyspace) on AWS"
cqlsh localhost 9042 -e "CREATE KEYSPACE IF NOT EXISTS testdatabase WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1}"

figlet -w 200 -f small "Create Cassandra Tables on AWS"
cd /tmp
java -jar liquibase.jar --driver=com.simba.cassandra.jdbc42.Driver --url="jdbc:cassandra://localhost:9042/testdatabase;DefaultKeyspace=testdatabase" --username=cassandra --password=cassandra --classpath="CassandraJDBC42.jar:liquibase-cassandra-4.0.0.2.jar" --changeLogFile=changeset.cassandra.sql --defaultSchemaName=testdatabase update
cd -

figlet -w 200 -f small "Load Cassandra Data on AWS"
cqlsh localhost 9042 -e "COPY testdatabase.DERIVEDFACT (DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '/tmp/DERIVEDFACT.csv' WITH DELIMITER=',' AND HEADER=TRUE"
cqlsh localhost 9042 -e "COPY testdatabase.MEMBERHEALTHSTATE (MEMBERHEALTHSTATESKEY,EPISODEID,VERSIONNBR,STATETYPECD,STATECOMPONENTID,MEMBERID,HEALTHSTATESTATUSCD,HEALTHSTATESTATUSCHANGERSNCD,HEALTHSTATESTATUSCHANGEDT,HEALTHSTATECHANGEDT,SEVERITYLEVEL,COMPLETIONFLG,CLINICALREVIEWSTATUSCD,CLINICALREVIEWSTATUSDT,LASTEVALUATIONDT,VOIDFLG,INSERTEDBY,INSERTEDDT,UPDATEDBY,UPDATEDDT,SEVERITYSCORE,MASTERSUPPLIERID,YEARQTR,PDCSCOREPERC) FROM '/tmp/MEMBERHEALTHSTATE.csv' WITH DELIMITER=',' AND HEADER=TRUE"

figlet -w 200 -f small "Check Cassandra on AWS"
cqlsh localhost 9042 -e "select * from testdatabase.DERIVEDFACT;"
cqlsh localhost 9042 -e "select * from testdatabase.MEMBERHEALTHSTATE;"
