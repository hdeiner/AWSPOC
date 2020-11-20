### Starting out with Oracle

##### Concept

> [The] Oracle Corporation is an American multinational computer technology corporation headquartered in Redwood Shores, California. The company sells database software and technology, cloud engineered systems, and enterprise software products—particularly its own brands of database management systems. In 2019, Oracle was the second-largest software company by revenue and market capitalization. The company also develops and builds tools for database development and systems of middle-tier software, enterprise resource planning (ERP) software, Human Capital Management (HCM) software, customer relationship management (CRM) software, and supply chain management (SCM) software.
>
>Larry Ellison co-founded Oracle Corporation in 1977 with Bob Miner and Ed Oates under the name Software Development Laboratories (SDL). Ellison took inspiration from the 1970 paper written by Edgar F. Codd on relational database management systems (RDBMS) named "A Relational Model of Data for Large Shared Data Banks." He heard about the IBM System R database from an article in the IBM Research Journal provided by Oates. Ellison wanted to make Oracle's product compatible with System R, but failed to do so as IBM kept the error codes for their DBMS a secret. SDL changed its name to Relational Software, Inc (RSI) in 1979, then again to Oracle Systems Corporation in 1983, to align itself more closely with its flagship product Oracle Database. At this stage Bob Miner served as the company's senior programmer. On March 12, 1986, the company had its initial public offering.
> 
> In 1995, Oracle Systems Corporation changed its name to Oracle Corporation, officially named Oracle, but sometimes referred to as Oracle Corporation, the name of the holding company. Part of Oracle Corporation's early success arose from using the C programming language to implement its products. This eased porting to different operating systems most of which support C.
>
> https://en.wikipedia.org/wiki/Oracle_Corporation
>
>
> It's been a long time since 1977.  Today, Oracle revenue has risen to about $10B annually, with revenue of over $2B annually.  Larry Ellison has a personal net worth of almost $76B, according to Forbes.  Unhappily, the companay has not made many changes which keep up with the times, and has seduced it's users with wonderful features to stay relevant in a manner that is both closed and with a huge barrier to switch.  We are reaching the point where our company's future becomes an extension of Larry's largesse.  Should Larry decide that he would like to fund his hobby in souped up America's Cup high tech catamarans by trippling license fees, we would have no choice except to pay it.
>
> So, why is this experiment in here, you ask?  It should be a slam dunk to get HealthEngine working in the cloud with this.  It provides a baseline for performance against other implementations, and a baseline on the economics of moving away from Oracle at this time.  Furthermore, as far as risk mitigation goes, this should be a very safe move to get into the cloud.

#### Execution

We want to get into Oracle quickly.  So, before we start running AWS instances, we need to master our data and how we're going to instantiate it in the database.

This whole project is about rearchitecting the database behind CareEngine, and we will try several different databases to do that.

Rather than rewrite each SQL DDL into each database's dialect, I will use a tool called Liquibase, which can do two things.
<UL>
<LI>Emit SQL DDL specific to each database from a common changeset</LI>
<LI>Use the notion of changesets to allow us to migrate the database created from one version to another.</LI>
</UL>

### 01_startup.sh
This script uses docker-compose to take the latest Dockerhub OracleEnterprise 12.2.0.1 image and bring it up in a container running as a daemon.  Since Oracle wants to persist data, I use a Docker Volume, which I delete in 03_shutdown.sh

Since we do not want to make use of the database until it actually starts, I monitor the logs from the postgres_container until I see a signature which tells me that the database has started.
```bash
#!/usr/bin/env bash

figlet -w 160 -f small "Startup Oracle Locally"
docker volume rm 07_oracle_local_oracle_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For Oracle To Start"
while true ; do
  docker logs oracle_container > stdout.txt 2> stderr.txt
  result=$(grep -c "Done ! The database is ready for use ." stdout.txt)
  if [ $result = 1 ] ; then
    sleep 60 # it only thinks it is started
    echo "Oracle has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
```
### 02_populate.sh
This script first uses the running oracle_container, with it's default ORCLCDB database and runs liquibase to update the database to it's intended state.  Unhppily, liquibase does not run the loadData command corectly, which forces me to use the sqlldr found in the running container (since I'd rather not install Oracle and all of it's tools locally).  It also calls upon the oracle_container to do the select * from the tables to display data in them.

The script demonstrates that the tables created have data in them with the DDL managed by Liquibase..
```bash
#!/usr/bin/env bash

figlet -w 160 -f small "Populate Oracle Locally"

figlet -w 160 -f small "Apply Schema for Oracle Locally"
cp ../../src/java/Translator/changeSet.xml changeSet.xml
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended 's/schemaName\=\"CE\"//g' changeSet.xml
# modify the tablenames in constraints clauses to include the CE in from of the tablemame.
sed --in-place --regexp-extended 's/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1CE.\2\3/g' changeSet.xml
liquibase update

figlet -w 160 -f small "Get Data from S3 Bucket"
../../data/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
../../data/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv

figlet -w 160 -f small "Populate Oracle Locally"

echo "Clinical_Condition"
# add header
sed -i '1 i\CLINICAL_CONDITION_COD|CLINICAL_CONDITION_NAM|INSERTED_BY|REC_INSERT_DATE|REC_UPD_DATE|UPDATED_BY|CLINICALCONDITIONCLASSCD|CLINICALCONDITIONTYPECD|CLINICALCONDITIONABBREV' ce.Clinical_Condition.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.Clinical_Condition.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.Clinical_Condition.csv
# get rid of timestamps
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+//g' ce.Clinical_Condition.csv
# get rid of ^M (return characters)
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.Clinical_Condition.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Clinical_Condition.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Clinical_Condition.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.Clinical_Condition.csv
tr -d $'\r' < ce.Clinical_Condition.csv > ce.Clinical_Condition.csv.mod
docker cp ce.Clinical_Condition.csv.mod oracle_container:/ORCL/ce.Clinical_Condition.csv

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.Clinical_Condition.csv"' >> .control.ctl
echo '  truncate into table "CE.CLINICAL_CONDITION"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( CLINICAL_CONDITION_COD,' >> .control.ctl
echo '  CLINICAL_CONDITION_NAM,' >> .control.ctl
echo '  INSERTED_BY,' >> .control.ctl
echo '  REC_INSERT_DATE DATE "YYYY-MM-DD",' >> .control.ctl
echo '  REC_UPD_DATE DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDATED_BY,' >> .control.ctl
echo '  CLINICALCONDITIONCLASSCD,' >> .control.ctl
echo '  CLINICALCONDITIONTYPECD,' >> .control.ctl
echo '  CLINICALCONDITIONABBREV) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.Clinical_Condition.csv.mod oracle_container:/ORCL/ce.Clinical_Condition.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log


echo "DerivedFact"
# add header
sed -i '1 i\DERIVEDFACTID|DERIVEDFACTTRACKINGID|DERIVEDFACTTYPEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFact.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.DerivedFact.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.DerivedFact.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.DerivedFact.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.DerivedFact.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.DerivedFact.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.DerivedFact.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.DerivedFact.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.DerivedFact.csv > ce.DerivedFact.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.DerivedFact.csv"' >> .control.ctl
echo '  truncate into table "CE.DERIVEDFACT"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( DERIVEDFACTID,' >> .control.ctl
echo '  DERIVEDFACTTRACKINGID,' >> .control.ctl
echo '  DERIVEDFACTTYPEID,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.DerivedFact.csv.mod oracle_container:/ORCL/ce.DerivedFact.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "DerivedFactProductUsage"
# add header
sed -i '1 i\DERIVEDFACTPRODUCTUSAGEID|DERIVEDFACTID|PRODUCTMNEMONICCD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFactProductUsage.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.DerivedFactProductUsage.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.DerivedFactProductUsage.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.DerivedFactProductUsage.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.DerivedFactProductUsage.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.DerivedFactProductUsage.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.DerivedFactProductUsage.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.DerivedFactProductUsage.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.DerivedFactProductUsage.csv > ce.DerivedFactProductUsage.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.DerivedFactProductUsage.csv"' >> .control.ctl
echo '  truncate into table "CE.DERIVEDFACTPRODUCTUSAGE"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( DERIVEDFACTPRODUCTUSAGEID,' >> .control.ctl
echo '  DERIVEDFACTID,' >> .control.ctl
echo '  PRODUCTMNEMONICCD,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.DerivedFactProductUsage.csv.mod oracle_container:/ORCL/ce.DerivedFactProductUsage.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "MedicalFinding"
# add header
sed -i '1 i\MEDICALFINDINGID|MEDICALFINDINGTYPECD|MEDICALFINDINGNM|SEVERITYLEVELCD|IMPACTABLEFLG|CLINICAL_CONDITION_COD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|ACTIVEFLG|OPPORTUNITYPOINTSDISCRCD' ce.MedicalFinding.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.MedicalFinding.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.MedicalFinding.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.MedicalFinding.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.MedicalFinding.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.MedicalFinding.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.MedicalFinding.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.MedicalFinding.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.MedicalFinding.csv > ce.MedicalFinding.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.MedicalFinding.csv"' >> .control.ctl
echo '  truncate into table "CE.MEDICALFINDING"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( MEDICALFINDINGID,' >> .control.ctl
echo '  MEDICALFINDINGTYPECD,' >> .control.ctl
echo '  MEDICALFINDINGNM,' >> .control.ctl
echo '  SEVERITYLEVELCD,' >> .control.ctl
echo '  IMPACTABLEFLG,' >> .control.ctl
echo '  CLINICAL_CONDITION_COD,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY,' >> .control.ctl
echo '  ACTIVEFLG,' >> .control.ctl
echo '  OPPORTUNITYPOINTSDISCRCD) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.MedicalFinding.csv.mod oracle_container:/ORCL/ce.MedicalFinding.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "MedicalFindingType"
# add header
sed -i '1 i\MEDICALFINDINGTYPECD|MEDICALFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|HEALTHSTATEAPPLICABLEFLAG' ce.MedicalFindingType.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.MedicalFindingType.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.MedicalFindingType.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.MedicalFindingType.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.MedicalFindingType.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.MedicalFindingType.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.MedicalFindingType.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.MedicalFindingType.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.MedicalFindingType.csv > ce.MedicalFindingType.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.MedicalFindingType.csv"' >> .control.ctl
echo '  truncate into table "CE.MEDICALFINDINGTYPE"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( MEDICALFINDINGTYPECD,' >> .control.ctl
echo '  MEDICALFINDINGTYPEDESC,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY,' >> .control.ctl
echo '  HEALTHSTATEAPPLICABLEFLAG) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.MedicalFindingType.csv.mod oracle_container:/ORCL/ce.MedicalFindingType.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "OpportunityPointsDiscr"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCRCD|OPPORTUNITYPOINTSDISCNM|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.OpportunityPointsDiscr.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.OpportunityPointsDiscr.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.OpportunityPointsDiscr.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.OpportunityPointsDiscr.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.OpportunityPointsDiscr.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.OpportunityPointsDiscr.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.OpportunityPointsDiscr.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.OpportunityPointsDiscr.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.OpportunityPointsDiscr.csv > ce.OpportunityPointsDiscr.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.OpportunityPointsDiscr.csv"' >> .control.ctl
echo '  truncate into table "CE.OPPORTUNITYPOINTSDISCR"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( OPPORTUNITYPOINTSDISCRCD,' >> .control.ctl
echo '  OPPORTUNITYPOINTSDISCNM,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.OpportunityPointsDiscr.csv.mod oracle_container:/ORCL/ce.OpportunityPointsDiscr.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "ProductFinding"
# add header
sed -i '1 i\PRODUCTFINDINGID|PRODUCTFINDINGNM|SEVERITYLEVELCD|PRODUCTFINDINGTYPECD|PRODUCTMNEMONICCD|SUBPRODUCTMNEMONICCD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|ACTIVEFLG|OPPORTUNITYPOINTSDISCRCD' ce.ProductFinding.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductFinding.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductFinding.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductFinding.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductFinding.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductFinding.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductFinding.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductFinding.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductFinding.csv > ce.ProductFinding.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.ProductFinding.csv"' >> .control.ctl
echo '  truncate into table "CE.PRODUCTFINDING"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( PRODUCTFINDINGID,' >> .control.ctl
echo '  PRODUCTFINDINGNM,' >> .control.ctl
echo '  SEVERITYLEVELCD,' >> .control.ctl
echo '  PRODUCTFINDINGTYPECD,' >> .control.ctl
echo '  PRODUCTMNEMONICCD,' >> .control.ctl
echo '  SUBPRODUCTMNEMONICCD,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductFinding.csv.mod oracle_container:/ORCL/ce.ProductFinding.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "ProductFindingType"
# add header
sed -i '1 i\PRODUCTFINDINGTYPECD|PRODUCTFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductFindingType.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductFindingType.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductFindingType.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductFindingType.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductFindingType.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductFindingType.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductFindingType.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductFindingType.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductFindingType.csv > ce.ProductFindingType.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.ProductFindingType.csv"' >> .control.ctl
echo '  truncate into table "CE.PRODUCTFINDINGTYPE"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( PRODUCTFINDINGTYPECD,' >> .control.ctl
echo '  PRODUCTFINDINGTYPEDESC,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductFindingType.csv.mod oracle_container:/ORCL/ce.ProductFindingType.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "ProductOpportunityPoints"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCCD|EFFECTIVESTARTDT|OPPORTUNITYPOINTSNBR|EFFECTIVEENDDT|DERIVEDFACTPRODUCTUSAGEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductOpportunityPoints.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductOpportunityPoints.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductOpportunityPoints.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductOpportunityPoints.csv
# get rid of timestamps without decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+[0-9]+//g' ce.ProductOpportunityPoints.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductOpportunityPoints.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductOpportunityPoints.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductOpportunityPoints.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductOpportunityPoints.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductOpportunityPoints.csv > ce.ProductOpportunityPoints.csv.mod

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.ProductOpportunityPoints.csv"' >> .control.ctl
echo '  truncate into table "CE.PRODUCTOPPORTUNITYPOINTS"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( OPPORTUNITYPOINTSDISCCD,' >> .control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  OPPORTUNITYPOINTSNBR,' >> .control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  DERIVEDFACTPRODUCTUSAGEID,' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  UPDTDBY) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductOpportunityPoints.csv.mod oracle_container:/ORCL/ce.ProductOpportunityPoints.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

echo "Recommendation"
# get rid of ^M (return characters)
tr -d $'\r' < ce.Recommendation.csv > ce.Recommendation.csv.mod
# Merge every other line in ce.Recommendation together with a comma between them
paste - - - -d'|' < ce.Recommendation.csv.mod > ce.Recommendation.csv
# add header
sed -i '1 i\RECOMMENDATIONSKEY|RECOMMENDATIONID|RECOMMENDATIONCODE|RECOMMENDATIONDESC|RECOMMENDATIONTYPE|CCTYPE|CLINICALREVIEWTYPE|AGERANGEID|ACTIONCODE|THERAPEUTICCLASS|MDCCODE|MCCCODE|PRIVACYCATEGORY|INTERVENTION|RECOMMENDATIONFAMILYID|RECOMMENDPRECEDENCEGROUPID|INBOUNDCOMMUNICATIONROUTE|SEVERITY|PRIMARYDIAGNOSIS|SECONDARYDIAGNOSIS|ADVERSEEVENT|ICMCONDITIONID|WELLNESSFLAG|VBFELIGIBLEFLAG|COMMUNICATIONRANKING|PRECEDENCERANKING|PATIENTDERIVEDFLAG|LABREQUIREDFLAG|UTILIZATIONTEXTAVAILABLEF|SENSITIVEMESSAGEFLAG|HIGHIMPACTFLAG|ICMLETTERFLAG|REQCLINICIANCLOSINGFLAG|OPSIMPELMENTATIONPHASE|SEASONALFLAG|SEASONALSTARTDT|SEASONALENDDT|EFFECTIVESTARTDT|EFFECTIVEENDDT|RECORDINSERTDT|RECORDUPDTDT|INSERTEDBY|UPDTDBY|STANDARDRUNFLAG|INTERVENTIONFEEDBACKFAMILYID|CONDITIONFEEDBACKFAMILYID|ASHWELLNESSELIGIBILITYFLAG|HEALTHADVOCACYELIGIBILITYFLAG' ce.Recommendation.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.Recommendation.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.Recommendation.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.Recommendation.csv
# get rid of timestamps without decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+[0-9]+//g' ce.Recommendation.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.Recommendation.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Recommendation.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Recommendation.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.Recommendation.csv
cp ce.Recommendation.csv ce.Recommendation.csv.mod


echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/ORCL/ce.Recommendation.csv"' >> .control.ctl
echo '  truncate into table "CE.RECOMMENDATION"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo '( RECOMMENDATIONSKEY,' >> .control.ctl
echo '  RECOMMENDATIONID,' >> .control.ctl
echo '  RECOMMENDATIONCODE,' >> .control.ctl
echo '  RECOMMENDATIONDESC,' >> .control.ctl
echo '  RECOMMENDATIONTYPE,' >> .control.ctl
echo '  CCTYPE,' >> .control.ctl
echo '  CLINICALREVIEWTYPE,' >> .control.ctl
echo '  AGERANGEID,' >> .control.ctl
echo '  ACTIONCODE,' >> .control.ctl
echo '  THERAPEUTICCLASS,' >> .control.ctl
echo '  MDCCODE,' >> .control.ctl
echo '  MCCCODE,' >> .control.ctl
echo '  PRIVACYCATEGORY,' >> .control.ctl
echo '  INTERVENTION,' >> .control.ctl
echo '  RECOMMENDATIONFAMILYID,' >> .control.ctl
echo '  RECOMMENDPRECEDENCEGROUPID,' >> .control.ctl
echo '  INBOUNDCOMMUNICATIONROUTE,' >> .control.ctl
echo '  SEVERITY,' >> .control.ctl
echo '  PRIMARYDIAGNOSIS,' >> .control.ctl
echo '  SECONDARYDIAGNOSIS,' >> .control.ctl
echo '  ADVERSEEVENT,' >> .control.ctl
echo '  ICMCONDITIONID,' >> .control.ctl
echo '  WELLNESSFLAG,' >> .control.ctl
echo '  VBFELIGIBLEFLAG,' >> .control.ctl
echo '  COMMUNICATIONRANKING,' >> .control.ctl
echo '  PRECEDENCERANKING,' >> .control.ctl
echo '  PATIENTDERIVEDFLAG,' >> .control.ctl
echo '  LABREQUIREDFLAG,' >> .control.ctl
echo '  UTILIZATIONTEXTAVAILABLEF,' >> .control.ctl
echo '  SENSITIVEMESSAGEFLAG,' >> .control.ctl
echo '  HIGHIMPACTFLAG,' >> .control.ctl
echo '  ICMLETTERFLAG,' >> .control.ctl
echo '  REQCLINICIANCLOSINGFLAG,' >> .control.ctl
echo '  OPSIMPELMENTATIONPHASE,' >> .control.ctl
echo '  SEASONALFLAG,' >> .control.ctl
echo '  SEASONALSTARTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  SEASONALENDDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> .control.ctl
echo '  INSERTEDBY,' >> .control.ctl
echo '  UPDTDBY,' >> .control.ctl
echo '  STANDARDRUNFLAG,' >> .control.ctl
echo '  INTERVENTIONFEEDBACKFAMILYID,' >> .control.ctl
echo '  CONDITIONFEEDBACKFAMILYID,' >> .control.ctl
echo '  ASHWELLNESSELIGIBILITYFLAG,' >> .control.ctl
echo '  HEALTHADVOCACYELIGIBILITYFLAG) ' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.Recommendation.csv.mod oracle_container:/ORCL/ce.Recommendation.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log

figlet -w 160 -f small "Check Oracle Locally"
echo 'SET LINESIZE 200;' >> .command.sql``
echo 'select * from "CE.CLINICAL_CONDITION" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.CLINICAL_CONDITION";' >> .command.sql``
echo 'select * from "CE.DERIVEDFACT" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.DERIVEDFACT";' >> .command.sql``
echo 'select * from "CE.DERIVEDFACTPRODUCTUSAGE" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.DERIVEDFACTPRODUCTUSAGE";' >> .command.sql``
echo 'select * from "CE.MEDICALFINDING" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.MEDICALFINDING";' >> .command.sql``
echo 'select * from "CE.MEDICALFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.MEDICALFINDINGTYPE";' >> .command.sql``
echo 'select * from "CE.OPPORTUNITYPOINTSDISCR" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.OPPORTUNITYPOINTSDISCR";' >> .command.sql``
echo 'select * from "CE.PRODUCTFINDING" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.PRODUCTFINDING";' >> .command.sql``
echo 'select * from "CE.PRODUCTFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.PRODUCTFINDINGTYPE";' >> .command.sql``
echo 'select * from "CE.PRODUCTOPPORTUNITYPOINTS" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.PRODUCTOPPORTUNITYPOINTS";' >> .command.sql``
echo 'select * from "CE.RECOMMENDATION" FETCH FIRST 2 ROWS ONLY;' >> .command.sql``
echo 'select count(*) from "CE.RECOMMENDATION";' >> .command.sql``
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql

rm .control.ctl .command.sql changeSet.xml *.csv *.mod
```
Liquibase itself is controlled by a liquibase.properties file for now.
```bash
changeLogFile: changeSet.xml
url: jdbc:oracle:thin:@localhost:1521:ORCLCDB
username:  system
password:  Oradoc_db1
driver: oracle.jdbc.OracleDriver
classpath:  ../../liquibase_drivers/ojdbc7.jar
```
It is also using the changeset generated by the ANTLR4 Translator.
```sql
--liquibase formatted sql



--changeset CE:1
CREATE TABLE CE.OPPORTUNITYPOINTSDISCR (
	OPPORTUNITYPOINTSDISCNM VARCHAR,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR,
	OPPORTUNITYPOINTSDISCRCD VARCHAR PRIMARY KEY
)
--rollback DROP TABLE CE.OPPORTUNITYPOINTSDISCR;


--changeset CE:2
CREATE TABLE CE.DERIVEDFACT (
	DERIVEDFACTTRACKINGID BIGINT,
	DERIVEDFACTTYPEID BIGINT,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR,
	DERIVEDFACTID BIGINT PRIMARY KEY
)
--rollback DROP TABLE CE.DERIVEDFACT;


--changeset CE:3
CREATE TABLE CE.RECOMMENDATIONTEXT (
	RECOMMENDATIONTEXTID BIGINT,
	RECOMMENDATIONID BIGINT PRIMARY KEY,
	LANGUAGECD VARCHAR,
	RECOMMENDATIONTEXTTYPE VARCHAR,
	MESSAGETYPE VARCHAR,
	RECOMMENDATIONTITLE VARCHAR,
	RECOMMENDATIONTEXT VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDATEDT DATE,
	INSERTEDBY VARCHAR,
	UPDATEDBY VARCHAR,
	DEFAULTIN VARCHAR
)
--rollback DROP TABLE CE.RECOMMENDATIONTEXT;


--changeset CE:4
CREATE TABLE CE.CLINICAL_CONDITION (
	CLINICAL_CONDITION_NAM VARCHAR,
	INSERTED_BY VARCHAR,
	REC_INSERT_DATE DATE,
	REC_UPD_DATE DATE,
	UPDATED_BY VARCHAR,
	CLINICALCONDITIONCLASSCD BIGINT,
	CLINICALCONDITIONTYPECD VARCHAR,
	CLINICALCONDITIONABBREV VARCHAR,
	CLINICAL_CONDITION_COD BIGINT PRIMARY KEY
)
--rollback DROP TABLE CE.CLINICAL_CONDITION;


--changeset CE:5
CREATE TABLE CE.PRODUCTOPPORTUNITYPOINTS (
	OPPORTUNITYPOINTSDISCCD VARCHAR PRIMARY KEY,
	EFFECTIVESTARTDT DATE,
	OPPORTUNITYPOINTSNBR BIGINT,
	EFFECTIVEENDDT DATE,
	DERIVEDFACTPRODUCTUSAGEID BIGINT,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR
)
--rollback DROP TABLE CE.PRODUCTOPPORTUNITYPOINTS;


--changeset CE:6
CREATE TABLE CE.MEDICALFINDING (
	MEDICALFINDINGID BIGINT PRIMARY KEY,
	MEDICALFINDINGTYPECD VARCHAR,
	MEDICALFINDINGNM VARCHAR,
	SEVERITYLEVELCD VARCHAR,
	IMPACTABLEFLG VARCHAR,
	CLINICAL_CONDITION_COD BIGINT,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR,
	ACTIVEFLG VARCHAR,
	OPPORTUNITYPOINTSDISCRCD VARCHAR
)
--rollback DROP TABLE CE.MEDICALFINDING;


--changeset CE:7
CREATE TABLE CE.DERIVEDFACTPRODUCTUSAGE (
	DERIVEDFACTID BIGINT,
	PRODUCTMNEMONICCD VARCHAR,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR,
	DERIVEDFACTPRODUCTUSAGEID BIGINT PRIMARY KEY
)
--rollback DROP TABLE CE.DERIVEDFACTPRODUCTUSAGE;


--changeset CE:8
CREATE TABLE CE.PRODUCTFINDINGTYPE (
	PRODUCTFINDINGTYPECD VARCHAR PRIMARY KEY,
	PRODUCTFINDINGTYPEDESC VARCHAR,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR
)
--rollback DROP TABLE CE.PRODUCTFINDINGTYPE;


--changeset CE:9
CREATE TABLE CE.RECOMMENDATION (
	RECOMMENDATIONSKEY BIGINT PRIMARY KEY,
	RECOMMENDATIONID BIGINT,
	RECOMMENDATIONCODE VARCHAR,
	RECOMMENDATIONDESC VARCHAR,
	RECOMMENDATIONTYPE VARCHAR,
	CCTYPE VARCHAR,
	CLINICALREVIEWTYPE VARCHAR,
	AGERANGEID BIGINT,
	ACTIONCODE VARCHAR,
	THERAPEUTICCLASS VARCHAR,
	MDCCODE VARCHAR,
	MCCCODE VARCHAR,
	PRIVACYCATEGORY VARCHAR,
	INTERVENTION VARCHAR,
	RECOMMENDATIONFAMILYID BIGINT,
	RECOMMENDPRECEDENCEGROUPID BIGINT,
	INBOUNDCOMMUNICATIONROUTE VARCHAR,
	SEVERITY VARCHAR,
	PRIMARYDIAGNOSIS VARCHAR,
	SECONDARYDIAGNOSIS VARCHAR,
	ADVERSEEVENT VARCHAR,
	ICMCONDITIONID BIGINT,
	WELLNESSFLAG VARCHAR,
	VBFELIGIBLEFLAG VARCHAR,
	COMMUNICATIONRANKING BIGINT,
	PRECEDENCERANKING BIGINT,
	PATIENTDERIVEDFLAG VARCHAR,
	LABREQUIREDFLAG VARCHAR,
	UTILIZATIONTEXTAVAILABLEF VARCHAR,
	SENSITIVEMESSAGEFLAG VARCHAR,
	HIGHIMPACTFLAG VARCHAR,
	ICMLETTERFLAG VARCHAR,
	REQCLINICIANCLOSINGFLAG VARCHAR,
	OPSIMPELMENTATIONPHASE BIGINT,
	SEASONALFLAG VARCHAR,
	SEASONALSTARTDT DATE,
	SEASONALENDDT DATE,
	EFFECTIVESTARTDT DATE,
	EFFECTIVEENDDT DATE,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	INSERTEDBY VARCHAR,
	UPDTDBY VARCHAR,
	STANDARDRUNFLAG VARCHAR,
	INTERVENTIONFEEDBACKFAMILYID BIGINT,
	CONDITIONFEEDBACKFAMILYID BIGINT,
	ASHWELLNESSELIGIBILITYFLAG VARCHAR,
	HEALTHADVOCACYELIGIBILITYFLAG VARCHAR
)
--rollback DROP TABLE CE.RECOMMENDATION;


--changeset CE:10
CREATE TABLE CE.PRODUCTFINDING (
	PRODUCTFINDINGID BIGINT PRIMARY KEY,
	PRODUCTFINDINGNM VARCHAR,
	SEVERITYLEVELCD VARCHAR,
	PRODUCTFINDINGTYPECD VARCHAR,
	PRODUCTMNEMONICCD VARCHAR,
	SUBPRODUCTMNEMONICCD VARCHAR,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR
)
--rollback DROP TABLE CE.PRODUCTFINDING;


--changeset CE:11
CREATE TABLE CE.MEDICALFINDINGTYPE (
	MEDICALFINDINGTYPEDESC VARCHAR,
	INSERTEDBY VARCHAR,
	RECORDINSERTDT DATE,
	RECORDUPDTDT DATE,
	UPDTDBY VARCHAR,
	HEALTHSTATEAPPLICABLEFLAG VARCHAR,
	MEDICALFINDINGTYPECD VARCHAR PRIMARY KEY
)
--rollback DROP TABLE CE.MEDICALFINDINGTYPE;

--changeset CE:12
CREATE TABLE CE.MEMBERHEALTHSTATE (
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
-- rollback DROP TABLE CE.MEMBERHEALTHSTATE;
```
### 03_shutdown.sh
This script is brutely simple.  It uses docker-compose to bring down the environment it established, and then uses docker volume rm to delete the data which held the bits for out database data.

```bash
#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown Oracle Locally"
docker-compose -f docker-compose.yml down
docker volume rm 07_oracle_local_oracle_data
```

### Putting it all together...

It all looks something like this:

![01_startup](README_assets/01_startup.png)\
<BR />
![02_populate_01](README_assets/02_populate_01.png)\
![02_populate_02](README_assets/02_populate_02.png)\
![02_populate_03](README_assets/02_populate_03.png)\
![02_populate_04](README_assets/02_populate_04.png)\
![02_populate_05](README_assets/02_populate_05.png)\
![02_populate_06](README_assets/02_populate_06.png)\
![02_populate_07](README_assets/02_populate_07.png)\
![02_populate_08](README_assets/02_populate_08.png)\
![02_populate_09](README_assets/02_populate_09.png)\
![02_populate_10](README_assets/02_populate_10.png)\
![02_populate_11](README_assets/02_populate_11.png)\
![02_populate_12](README_assets/02_populate_12.png)\
![02_populate_13](README_assets/02_populate_13.png)\
![02_populate_14](README_assets/02_populate_14.png)\
![02_populate_15](README_assets/02_populate_15.png)\
![02_populate_16](README_assets/02_populate_16.png)\
![02_populate_17](README_assets/02_populate_17.png)\
![02_populate_18](README_assets/02_populate_18.png)\
![02_populate_19](README_assets/02_populate_19.png)\
![02_populate_20](README_assets/02_populate_20.png)\
![02_populate_21](README_assets/02_populate_21.png)\
![02_populate_22](README_assets/02_populate_22.png)\
![02_populate_23](README_assets/02_populate_23.png)\
![02_populate_24](README_assets/02_populate_24.png)\
![02_populate_25](README_assets/02_populate_25.png)\
![02_populate_26](README_assets/02_populate_26.png)\
![02_populate_27](README_assets/02_populate_27.png)\
![02_populate_28](README_assets/02_populate_28.png)\
![02_populate_29](README_assets/02_populate_29.png)\
<BR />
![03_shutdown](README_assets/03_shutdown.png)\
<BR />

