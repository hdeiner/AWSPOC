#!/usr/bin/env bash

figlet -w 160 -f small "Populate Cassandra Locally"
docker exec cassandra_container cqlsh -e "CREATE KEYSPACE IF NOT EXISTS testdatabase WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1}"
liquibase update
docker cp ../../src/db/DERIVEDFACT.csv cassandra_container:/tmp/DERIVEDFACT.csv
docker exec cassandra_container cqlsh -e "COPY testdatabase.DERIVEDFACT (DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '/tmp/DERIVEDFACT.csv' WITH DELIMITER=',' AND HEADER=TRUE"
docker cp ../../src/db/MEMBERHEALTHSTATE.csv cassandra_container:/tmp/MEMBERHEALTHSTATE.csv
docker exec cassandra_container cqlsh -e "COPY testdatabase.MEMBERHEALTHSTATE (MEMBERHEALTHSTATESKEY,EPISODEID,VERSIONNBR,STATETYPECD,STATECOMPONENTID,MEMBERID,HEALTHSTATESTATUSCD,HEALTHSTATESTATUSCHANGERSNCD,HEALTHSTATESTATUSCHANGEDT,HEALTHSTATECHANGEDT,SEVERITYLEVEL,COMPLETIONFLG,CLINICALREVIEWSTATUSCD,CLINICALREVIEWSTATUSDT,LASTEVALUATIONDT,VOIDFLG,INSERTEDBY,INSERTEDDT,UPDATEDBY,UPDATEDDT,SEVERITYSCORE,MASTERSUPPLIERID,YEARQTR,PDCSCOREPERC) FROM '/tmp/MEMBERHEALTHSTATE.csv' WITH DELIMITER=',' AND HEADER=TRUE"

figlet -w 160 -f small "Check Cassandra Locally"
docker exec cassandra_container cqlsh  -e 'select * from testdatabase.DERIVEDFACT;'
docker exec cassandra_container cqlsh  -e 'select * from testdatabase.MEMBERHEALTHSTATE;'