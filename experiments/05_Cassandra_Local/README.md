### Starting out with Cassandra

##### Concept

> Apache Cassandra is a free and open-source, distributed, wide column store, NoSQL database management system designed to handle large amounts of data across many commodity servers, providing high availability with no single point of failure. Cassandra offers robust support for clusters spanning multiple datacenters, with asynchronous masterless replication allowing low latency operations for all clients. Cassandra offers the distribution design of Amazon DynamoDB with the data model of Google's Bigtable.
> 
> Avinash Lakshman, one of the authors of Amazon's Dynamo, and Prashant Malik initially developed Cassandra at Facebook to power the Facebook inbox search feature. Facebook released Cassandra as an open-source project on Google code in July 2008. In March 2009 it became an Apache Incubator project. On February 17, 2010 it graduated to a top-level project.
>
> Facebook developers named their database after the Trojan mythological prophet Cassandra, with classical allusions to a curse on an oracle.
>
> https://en.wikipedia.org/wiki/Apache_Cassandra
>
> https://cassandra.apache.org

Why Cassandra?
<UL>
<LI>Designed for massive data</LI>
<LI>Designed to be fault tolerant</LI>
<LI>Built in peer-to-peer distribution synchronization</LI>
</UL>

#### Execution

We want to get into Cassandra quickly.  So, before we start running AWS instances, we need to master our data and how we're going to instantiate it in the database.

This whole project is about rearchitecting the database behind CareEngine, and we will try several different databases to do that.

Rather than rewrite each SQL DDL into each database's dialect, I will use a tool called Liquibase, which can do two things.
<UL>
<LI>Emit SQL DDL specific to each database from a common changeset</LI>
<LI>Use the notion of changesets to allow us to migrate the database created from one version to another.</LI>
</UL>
Unhappily, Liquibase support for Cassandra does not support the changeset.xml format yet.  That still seems to be under active development.  Never the less, we can use Liquibase with just the native cqlsh client, and achieve the same goals.  

### 01_startup.sh
This script uses docker-compose to take the 3.8.11 Dockerhub Cassandra image and bring it up in a container running as a daemon.  Since Cassandra wants to persist data, I use a Docker Volume, which I delete in 03_shutdown.sh

Since we do not want to make use of the database until it actually starts, I monitor the logs from the cassandra_container until I see a signature which tells me that the database has started.
```bash
#!/usr/bin/env bash

figlet -w 160 -f small "Startup Cassandra Locally"
docker volume rm 01_Cassandra_local_cassandra_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For Cassandra To Start"
while true ; do
  docker logs cassandra_container > stdout.txt 2> stderr.txt
  result=$(grep -c "CassandraRoleManager.java:372 - Created default superuser role 'cassandra'" stdout.txt)
  if [ $result = 1 ] ; then
    echo "Cassandra has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
```
### 02_populate.sh
This script first uses the running cassandra_container to run cqlsh to create a database (keystore) for us.

The script then runs liquibase to update the database to it's intended state.  More on that in a bit.

The script then demonstrates that the two tables created have data in them, all managed by liquibase.  Since Liquibase is being used in a native sql form, I also have to import the csv data using native cqlsh COPY commands.
```bash
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
```
Liquibase itself is controlled by a liquibase.properties file for now.
```bash
changeLogFile: ../../src/db/changeset.cassandra.sql
url:  jdbc:cassandra://localhost:9042/testdatabase;DefaultKeyspace=testdatabase
username:  cassandra
password:  cassandra
driver: com.simba.cassandra.jdbc42.Driver
defaultSchemaName: testdatabase
classpath:  ../../liquibase_drivers/CassandraJDBC42.jar:../../liquibase_drivers/liquibase-cassandra-4.0.0.2.jar
```
It is also using this changeset.cassandrq.sql
```sql
--liquibase formatted sql

--changeset howarddeiner:1
CREATE TABLE testdatabase.DERIVEDFACT (
    DERIVEDFACTID BIGINT PRIMARY KEY,
    DERIVEDFACTTRACKINGID BIGINT,
    DERIVEDFACTTYPEID BIGINT,
    INSERTEDBY VARCHAR,
    RECORDINSERTDT DATE,
    RECORDUPDTDT DATE,
    UPDTDBY VARCHAR
)
-- rollback DROP TABLE testdatabase.DERIVEDFACT;

--changeset howarddeiner:2
CREATE TABLE testdatabase.MEMBERHEALTHSTATE (
    MEMBERHEALTHSTATESKEY BIGINT PRIMARY KEY,
    EPISODEID BIGINT,
    VERSIONNBR BIGINT,
    STATETYPECD VARCHAR,
    STATECOMPONENTID BIGINT,
    MEMBERID BIGINT,
    HEALTHSTATESTATUSCD VARCHAR,
    HEALTHSTATESTATUSCHANGERSNCD VARCHAR,
    HEALTHSTATESTATUSCHANGEDT DATE,
    HEALTHSTATECHANGEDT DATE,
    SEVERITYLEVEL VARCHAR,
    COMPLETIONFLG VARCHAR,
    CLINICALREVIEWSTATUSCD VARCHAR,
    CLINICALREVIEWSTATUSDT DATE,
    LASTEVALUATIONDT DATE,
    VOIDFLG VARCHAR,
    INSERTEDBY VARCHAR,
    INSERTEDDT DATE,
    UPDATEDBY VARCHAR,
    UPDATEDDT DATE,
    SEVERITYSCORE BIGINT,
    MASTERSUPPLIERID BIGINT,
    YEARQTR BIGINT,
    PDCSCOREPERC BIGINT
)
-- rollback DROP TABLE testdatabase.MEMBERHEALTHSTATE;
```

### 03_shutdown.sh
This script is brutely simple.  It uses docker-compose to bring down the environment it established, and then uses docker volume rm to delete the data which held the bits for out database data.

```bash
#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown Cassandra Locally"
docker-compose -f docker-compose.yml down
docker volume rm 01_cassandra_local_cassandra_data
```

### Putting it all together...

It all looks something like this:

![01_startup](README_assets/01_startup.png)\
<BR />
![02_populate_01](README_assets/02_populate_01.png)\
![02_populate_02](README_assets/02_populate_02.png)\
<BR />
![03_shutdown](README_assets/03_shutdown.png)\
<BR />
