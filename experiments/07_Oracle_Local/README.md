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

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Startup Oracle Locally"
docker volume rm 07_oracle_local_oracle_data
docker-compose -f docker-compose.yml up -d

echo "Wait For Oracle To Start"
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
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Startup Oracle Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
```
### 02_populate.sh
This script first uses the running oracle_container, with it's default ORCLCDB database and runs liquibase to update the database to it's intended state.  Unhppily, liquibase does not run the loadData command corectly, which forces me to use the sqlldr found in the running container (since I'd rather not install Oracle and all of it's tools locally).  It also calls upon the oracle_container to do the select * from the tables to display data in them.

The script demonstrates that the tables created have data in them with the DDL managed by Liquibase..
```bash
#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Oracle Locally"

figlet -w 240 -f small "Apply Schema for Oracle Locally"
cp ../../src/java/Translator/changeSet.xml changeSet.xml
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended '"'"'s/schemaName\=\"CE\"//g'"'"' changeSet.xml
# modify the tablenames in constraints clauses to include the CE in from of the tablemame.
sed --in-place --regexp-extended '"'"'s/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1CE.\2\3/g'"'"' changeSet.xml
liquibase update
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Populate Oracle Schema" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transfer_from_s3_and_decrypt.sh ce.ClinicalCondition.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
../../data/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Get Data from S3 Bucket" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into CSV Files For Import"
../transform_Oracle_ce.ClinicalCondition_to_csv.sh
../transform_Oracle_ce.DerivedFact_to_csv.sh
../transform_Oracle_ce.DerivedFactProductUsage_to_csv.sh
../transform_Oracle_ce.MedicalFinding_to_csv.sh
../transform_Oracle_ce.MedicalFindingType_to_csv.sh
../transform_Oracle_ce.OpportunityPointsDiscr_to_csv.sh
../transform_Oracle_ce.ProductFinding_to_csv.sh
../transform_Oracle_ce.ProductFindingType_to_csv.sh
../transform_Oracle_ce.ProductOpportunityPoints_to_csv.sh
../transform_Oracle_ce.Recommendation_to_csv.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Process S3 Data into CSV Files For Import" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Oracle Data"
echo "ClinicalCondition"
echo '"'"'options  ( skip=1 ) '"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.ClinicalCondition.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.CLINICAL_CONDITION"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( CLINICAL_CONDITION_COD,'"'"' >> .control.ctl
echo '"'"'  CLINICAL_CONDITION_NAM,'"'"' >> .control.ctl
echo '"'"'  INSERTED_BY,'"'"' >> .control.ctl
echo '"'"'  REC_INSERT_DATE DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  REC_UPD_DATE DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDATED_BY,'"'"' >> .control.ctl
echo '"'"'  CLINICALCONDITIONCLASSCD,'"'"' >> .control.ctl
echo '"'"'  CLINICALCONDITIONTYPECD,'"'"' >> .control.ctl
echo '"'"'  CLINICALCONDITIONABBREV) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ClinicalCondition.csv oracle_container:/ORCL/ce.ClinicalCondition.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "DerivedFact"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.DerivedFact.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.DERIVEDFACT"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( DERIVEDFACTID,'"'"' >> .control.ctl
echo '"'"'  DERIVEDFACTTRACKINGID,'"'"' >> .control.ctl
echo '"'"'  DERIVEDFACTTYPEID,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.DerivedFact.csv oracle_container:/ORCL/ce.DerivedFact.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "DerivedFactProductUsage"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.DerivedFactProductUsage.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.DERIVEDFACTPRODUCTUSAGE"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( DERIVEDFACTPRODUCTUSAGEID,'"'"' >> .control.ctl
echo '"'"'  DERIVEDFACTID,'"'"' >> .control.ctl
echo '"'"'  PRODUCTMNEMONICCD,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.DerivedFactProductUsage.csv oracle_container:/ORCL/ce.DerivedFactProductUsage.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "MedicalFinding"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.MedicalFinding.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.MEDICALFINDING"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( MEDICALFINDINGID,'"'"' >> .control.ctl
echo '"'"'  MEDICALFINDINGTYPECD,'"'"' >> .control.ctl
echo '"'"'  MEDICALFINDINGNM,'"'"' >> .control.ctl
echo '"'"'  SEVERITYLEVELCD,'"'"' >> .control.ctl
echo '"'"'  IMPACTABLEFLG,'"'"' >> .control.ctl
echo '"'"'  CLINICAL_CONDITION_COD,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY,'"'"' >> .control.ctl
echo '"'"'  ACTIVEFLG,'"'"' >> .control.ctl
echo '"'"'  OPPORTUNITYPOINTSDISCRCD) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.MedicalFinding.csv oracle_container:/ORCL/ce.MedicalFinding.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "MedicalFindingType"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.MedicalFindingType.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.MEDICALFINDINGTYPE"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( MEDICALFINDINGTYPECD,'"'"' >> .control.ctl
echo '"'"'  MEDICALFINDINGTYPEDESC,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY,'"'"' >> .control.ctl
echo '"'"'  HEALTHSTATEAPPLICABLEFLAG) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.MedicalFindingType.csv oracle_container:/ORCL/ce.MedicalFindingType.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "OpportunityPointsDiscr"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.OpportunityPointsDiscr.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.OPPORTUNITYPOINTSDISCR"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( OPPORTUNITYPOINTSDISCRCD,'"'"' >> .control.ctl
echo '"'"'  OPPORTUNITYPOINTSDISCNM,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.OpportunityPointsDiscr.csv oracle_container:/ORCL/ce.OpportunityPointsDiscr.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "ProductFinding"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.ProductFinding.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.PRODUCTFINDING"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( PRODUCTFINDINGID,'"'"' >> .control.ctl
echo '"'"'  PRODUCTFINDINGNM,'"'"' >> .control.ctl
echo '"'"'  SEVERITYLEVELCD,'"'"' >> .control.ctl
echo '"'"'  PRODUCTFINDINGTYPECD,'"'"' >> .control.ctl
echo '"'"'  PRODUCTMNEMONICCD,'"'"' >> .control.ctl
echo '"'"'  SUBPRODUCTMNEMONICCD,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductFinding.csv oracle_container:/ORCL/ce.ProductFinding.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "ProductFindingType"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.ProductFindingType.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.PRODUCTFINDINGTYPE"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( PRODUCTFINDINGTYPECD,'"'"' >> .control.ctl
echo '"'"'  PRODUCTFINDINGTYPEDESC,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductFindingType.csv oracle_container:/ORCL/ce.ProductFindingType.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "ProductOpportunityPoints"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.ProductOpportunityPoints.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.PRODUCTOPPORTUNITYPOINTS"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( OPPORTUNITYPOINTSDISCCD,'"'"' >> .control.ctl
echo '"'"'  EFFECTIVESTARTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  OPPORTUNITYPOINTSNBR,'"'"' >> .control.ctl
echo '"'"'  EFFECTIVEENDDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  DERIVEDFACTPRODUCTUSAGEID,'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  UPDTDBY) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.ProductOpportunityPoints.csv oracle_container:/ORCL/ce.ProductOpportunityPoints.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
echo "Recommendation"
echo '"'"'options  ( skip=1 )'"'"' > .control.ctl
echo '"'"'load data'"'"' >> .control.ctl
echo '"'"'  infile "/ORCL/ce.Recommendation.csv"'"'"' >> .control.ctl
echo '"'"'  truncate into table "CE.RECOMMENDATION"'"'"' >> .control.ctl
echo '"'"'fields terminated by ","'"'"' >> .control.ctl
echo '"'"'( RECOMMENDATIONSKEY,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDATIONID,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDATIONCODE,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDATIONDESC,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDATIONTYPE,'"'"' >> .control.ctl
echo '"'"'  CCTYPE,'"'"' >> .control.ctl
echo '"'"'  CLINICALREVIEWTYPE,'"'"' >> .control.ctl
echo '"'"'  AGERANGEID,'"'"' >> .control.ctl
echo '"'"'  ACTIONCODE,'"'"' >> .control.ctl
echo '"'"'  THERAPEUTICCLASS,'"'"' >> .control.ctl
echo '"'"'  MDCCODE,'"'"' >> .control.ctl
echo '"'"'  MCCCODE,'"'"' >> .control.ctl
echo '"'"'  PRIVACYCATEGORY,'"'"' >> .control.ctl
echo '"'"'  INTERVENTION,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDATIONFAMILYID,'"'"' >> .control.ctl
echo '"'"'  RECOMMENDPRECEDENCEGROUPID,'"'"' >> .control.ctl
echo '"'"'  INBOUNDCOMMUNICATIONROUTE,'"'"' >> .control.ctl
echo '"'"'  SEVERITY,'"'"' >> .control.ctl
echo '"'"'  PRIMARYDIAGNOSIS,'"'"' >> .control.ctl
echo '"'"'  SECONDARYDIAGNOSIS,'"'"' >> .control.ctl
echo '"'"'  ADVERSEEVENT,'"'"' >> .control.ctl
echo '"'"'  ICMCONDITIONID,'"'"' >> .control.ctl
echo '"'"'  WELLNESSFLAG,'"'"' >> .control.ctl
echo '"'"'  VBFELIGIBLEFLAG,'"'"' >> .control.ctl
echo '"'"'  COMMUNICATIONRANKING,'"'"' >> .control.ctl
echo '"'"'  PRECEDENCERANKING,'"'"' >> .control.ctl
echo '"'"'  PATIENTDERIVEDFLAG,'"'"' >> .control.ctl
echo '"'"'  LABREQUIREDFLAG,'"'"' >> .control.ctl
echo '"'"'  UTILIZATIONTEXTAVAILABLEF,'"'"' >> .control.ctl
echo '"'"'  SENSITIVEMESSAGEFLAG,'"'"' >> .control.ctl
echo '"'"'  HIGHIMPACTFLAG,'"'"' >> .control.ctl
echo '"'"'  ICMLETTERFLAG,'"'"' >> .control.ctl
echo '"'"'  REQCLINICIANCLOSINGFLAG,'"'"' >> .control.ctl
echo '"'"'  OPSIMPELMENTATIONPHASE,'"'"' >> .control.ctl
echo '"'"'  SEASONALFLAG,'"'"' >> .control.ctl
echo '"'"'  SEASONALSTARTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  SEASONALENDDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  EFFECTIVESTARTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  EFFECTIVEENDDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> .control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> .control.ctl
echo '"'"'  UPDTDBY,'"'"' >> .control.ctl
echo '"'"'  STANDARDRUNFLAG,'"'"' >> .control.ctl
echo '"'"'  INTERVENTIONFEEDBACKFAMILYID,'"'"' >> .control.ctl
echo '"'"'  CONDITIONFEEDBACKFAMILYID,'"'"' >> .control.ctl
echo '"'"'  ASHWELLNESSELIGIBILITYFLAG,'"'"' >> .control.ctl
echo '"'"'  HEALTHADVOCACYELIGIBILITYFLAG) '"'"' >> .control.ctl
docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker cp ce.Recommendation.csv oracle_container:/ORCL/ce.Recommendation.csv
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Populate Oracle Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Oracle Data"
echo ""
echo "ClinicalCondition"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN CLINICAL_CONDITION_NAM FORMAT A22;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTED_BY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN UPDATED_BY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONDESC FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN CLINICALCONDITIONABBREV FORMAT A18;'"'"' >> .command.sql
echo '"'"'select * from "CE.CLINICAL_CONDITION" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.CLINICAL_CONDITION";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "DerivedFact"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.DERIVEDFACT" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.DERIVEDFACT";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "DerivedFactProductUsage"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN PRODUCTMNEMONICCD FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.DERIVEDFACTPRODUCTUSAGE" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.DERIVEDFACTPRODUCTUSAGE";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "MedicalFinding"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN MEDICALFINDINGNM FORMAT A30;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.MEDICALFINDING" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.MEDICALFINDING";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "MedicalFindingType"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN MEDICALFINDINGTYPEDESC FORMAT A30;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.MEDICALFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.MEDICALFINDINGTYPE";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "OppurtunityPointsDiscr"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSDISCNM FORMAT A30;'"'"' >> .command.sql
echo '"'"'select * from "CE.OPPORTUNITYPOINTSDISCR" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.OPPORTUNITYPOINTSDISCR";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "ProductFinding"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN PRODUCTFINDINGNM FORMAT A30;'"'"' >> .command.sql
echo '"'"'COLUMN PRODUCTMNEMONICCD FORMAT A20;'"'"' >> .command.sql
echo '"'"'COLUMN SUBPRODUCTMNEMONICCD FORMAT A20;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.PRODUCTFINDING" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.PRODUCTFINDING";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "ProductFindingType"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN PRODUCTFINDINGTYPEDESC FORMAT A30;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.PRODUCTFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.PRODUCTFINDINGTYPE";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|^$/d'"'"'
echo ""
echo "ProductOpportunityPoints"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSDISCCD FORMAT A20;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> .command.sql
echo '"'"'select * from "CE.PRODUCTOPPORTUNITYPOINTS" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.PRODUCTOPPORTUNITYPOINTS";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d'"'"'
echo ""
echo "Recommendation"
echo '"'"'SET LINESIZE 240; '"'"' > .command.sql
echo '"'"'SET WRAP OFF;'"'"' >> .command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> .command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONSKEY FORMAT 999;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONID FORMAT 999;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONCODE FORMAT A18;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONDESC FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONTYPE FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN RECOMMENDATIONTYPE FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN CCTYPE FORMAT A20;'"'"' >> .command.sql
echo '"'"'COLUMN ACTIONCODE FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN MDCCODE FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN MCCCODE FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN PRIVACYCATEGORY FORMAT A1;'"'"' >> .command.sql
echo '"'"'COLUMN INTERVENTION FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN CLINICALREVIEWTYPE FORMAT A4;'"'"' >> .command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSNBR FORMAT 999;'"'"' >> .command.sql
echo '"'"'COLUMN DERIVEDFACTPRODUCTUSAGEID FORMAT 999999;'"'"' >> .command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN PRIMARYDIAGNOSIS FORMAT A10;'"'"' >> .command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A9;'"'"' >> .command.sql
echo '"'"'COLUMN THERAPEUTICCLASS FORMAT A16;'"'"' >> .command.sql
echo '"'"'select * from "CE.RECOMMENDATION" FETCH FIRST 2 ROWS ONLY;'"'"' >> .command.sql
echo '"'"'select count(*) from "CE.RECOMMENDATION";'"'"' >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d'"'"'
rm .control.ctl .command.sql changeSet.xml
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Check Oracle Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results *.csv
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
<?xml version="1.0" encoding="UTF-8"?>

<databaseChangeLog
	xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
	http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">

	<changeSet  id="1"  author="ce">

		<createTable tableName="CE.OPPORTUNITYPOINTSDISCR" schemaName="CE">
			<column name="OPPORTUNITYPOINTSDISCNM" type="VARCHAR2(255)"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="OPPORTUNITYPOINTSDISCRCD" type="VARCHAR2(12)">
				<constraints primaryKey="true"/>
			</column>
		</createTable>

		<createTable tableName="CE.DERIVEDFACT" schemaName="CE">
			<column name="DERIVEDFACTTRACKINGID" type="bigint"/>
			<column name="DERIVEDFACTTYPEID" type="bigint"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="DERIVEDFACTID" type="bigint">
				<constraints primaryKey="true"/>
			</column>
		</createTable>

		<createTable tableName="CE.RECOMMENDATIONTEXT" schemaName="CE">
			<column name="RECOMMENDATIONTEXTID" type="bigint"/>
			<column name="RECOMMENDATIONID" type="NUMBER(10,0)"/>
			<column name="LANGUAGECD" type="CHAR(2)"/>
			<column name="RECOMMENDATIONTEXTTYPE" type="VARCHAR2(20)"/>
			<column name="MESSAGETYPE" type="CHAR(3)"/>
			<column name="RECOMMENDATIONTITLE" type="VARCHAR2(200)"/>
			<column name="RECOMMENDATIONTEXT" type="VARCHAR2(4000)"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDATEDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="UPDATEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="DEFAULTIN" type="CHAR(1)"/>
		</createTable>

		<createTable tableName="CE.CLINICAL_CONDITION" schemaName="CE">
			<column name="CLINICAL_CONDITION_NAM" type="VARCHAR2(200)"/>
			<column name="INSERTED_BY" type="VARCHAR2(50)"/>
			<column name="REC_INSERT_DATE" type="DATE"/>
			<column name="REC_UPD_DATE" type="DATE"/>
			<column name="UPDATED_BY" type="VARCHAR2(50)"/>
			<column name="CLINICALCONDITIONCLASSCD" type="bigint"/>
			<column name="CLINICALCONDITIONTYPECD" type="VARCHAR2(12)"/>
			<column name="CLINICALCONDITIONABBREV" type="VARCHAR2(50)"/>
			<column name="CLINICAL_CONDITION_COD" type="bigint">
				<constraints primaryKey="true"/>
			</column>
		</createTable>

		<createTable tableName="CE.PRODUCTOPPORTUNITYPOINTS" schemaName="CE">
			<column name="OPPORTUNITYPOINTSDISCCD" type="VARCHAR2(100)"/>
			<column name="EFFECTIVESTARTDT" type="DATE"/>
			<column name="OPPORTUNITYPOINTSNBR" type="bigint"/>
			<column name="EFFECTIVEENDDT" type="DATE"/>
			<column name="DERIVEDFACTPRODUCTUSAGEID" type="bigint"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
		</createTable>

		<createTable tableName="CE.MEDICALFINDING" schemaName="CE">
			<column name="MEDICALFINDINGID" type="bigint"/>
			<column name="MEDICALFINDINGTYPECD" type="VARCHAR2(12)"/>
			<column name="MEDICALFINDINGNM" type="VARCHAR2(200)"/>
			<column name="SEVERITYLEVELCD" type="VARCHAR2(12)"/>
			<column name="IMPACTABLEFLG" type="CHAR(1)"/>
			<column name="CLINICAL_CONDITION_COD" type="bigint"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="ACTIVEFLG" type="CHAR(1)"/>
			<column name="OPPORTUNITYPOINTSDISCRCD" type="VARCHAR2(12)"/>
		</createTable>

		<createTable tableName="CE.DERIVEDFACTPRODUCTUSAGE" schemaName="CE">
			<column name="DERIVEDFACTID" type="bigint"/>
			<column name="PRODUCTMNEMONICCD" type="VARCHAR2(50)"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="DERIVEDFACTPRODUCTUSAGEID" type="bigint">
				<constraints primaryKey="true"/>
			</column>
		</createTable>

		<createTable tableName="CE.PRODUCTFINDINGTYPE" schemaName="CE">
			<column name="PRODUCTFINDINGTYPECD" type="VARCHAR2(12)"/>
			<column name="PRODUCTFINDINGTYPEDESC" type="VARCHAR2(255)"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
		</createTable>

		<createTable tableName="CE.RECOMMENDATION" schemaName="CE">
			<column name="RECOMMENDATIONSKEY" type="bigint"/>
			<column name="RECOMMENDATIONID" type="NUMBER(10,0)"/>
			<column name="RECOMMENDATIONCODE" type="VARCHAR2(200)"/>
			<column name="RECOMMENDATIONDESC" type="VARCHAR2(4000)"/>
			<column name="RECOMMENDATIONTYPE" type="VARCHAR2(20)"/>
			<column name="CCTYPE" type="VARCHAR2(50)"/>
			<column name="CLINICALREVIEWTYPE" type="VARCHAR2(20)"/>
			<column name="AGERANGEID" type="bigint"/>
			<column name="ACTIONCODE" type="VARCHAR2(200)"/>
			<column name="THERAPEUTICCLASS" type="VARCHAR2(300)"/>
			<column name="MDCCODE" type="VARCHAR2(20)"/>
			<column name="MCCCODE" type="VARCHAR2(50)"/>
			<column name="PRIVACYCATEGORY" type="VARCHAR2(20)"/>
			<column name="INTERVENTION" type="VARCHAR2(200)"/>
			<column name="RECOMMENDATIONFAMILYID" type="bigint"/>
			<column name="RECOMMENDPRECEDENCEGROUPID" type="bigint"/>
			<column name="INBOUNDCOMMUNICATIONROUTE" type="VARCHAR2(15)"/>
			<column name="SEVERITY" type="VARCHAR2(2)"/>
			<column name="PRIMARYDIAGNOSIS" type="VARCHAR2(300)"/>
			<column name="SECONDARYDIAGNOSIS" type="VARCHAR2(300)"/>
			<column name="ADVERSEEVENT" type="VARCHAR2(300)"/>
			<column name="ICMCONDITIONID" type="bigint"/>
			<column name="WELLNESSFLAG" type="CHAR(1)"/>
			<column name="VBFELIGIBLEFLAG" type="CHAR(1)"/>
			<column name="COMMUNICATIONRANKING" type="bigint"/>
			<column name="PRECEDENCERANKING" type="bigint"/>
			<column name="PATIENTDERIVEDFLAG" type="CHAR(1)"/>
			<column name="LABREQUIREDFLAG" type="CHAR(1)"/>
			<column name="UTILIZATIONTEXTAVAILABLEF" type="CHAR(1)"/>
			<column name="SENSITIVEMESSAGEFLAG" type="CHAR(1)"/>
			<column name="HIGHIMPACTFLAG" type="CHAR(1)"/>
			<column name="ICMLETTERFLAG" type="CHAR(1)"/>
			<column name="REQCLINICIANCLOSINGFLAG" type="CHAR(1)"/>
			<column name="OPSIMPELMENTATIONPHASE" type="bigint"/>
			<column name="SEASONALFLAG" type="CHAR(1)"/>
			<column name="SEASONALSTARTDT" type="DATE"/>
			<column name="SEASONALENDDT" type="DATE"/>
			<column name="EFFECTIVESTARTDT" type="DATE"/>
			<column name="EFFECTIVEENDDT" type="DATE"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="STANDARDRUNFLAG" type="CHAR(1)"/>
			<column name="INTERVENTIONFEEDBACKFAMILYID" type="bigint"/>
			<column name="CONDITIONFEEDBACKFAMILYID" type="bigint"/>
			<column name="ASHWELLNESSELIGIBILITYFLAG" type="CHAR(1)"/>
			<column name="HEALTHADVOCACYELIGIBILITYFLAG" type="CHAR(1)"/>
		</createTable>

		<createTable tableName="CE.PRODUCTFINDING" schemaName="CE">
			<column name="PRODUCTFINDINGID" type="bigint"/>
			<column name="PRODUCTFINDINGNM" type="VARCHAR2(100)"/>
			<column name="SEVERITYLEVELCD" type="VARCHAR2(12)"/>
			<column name="PRODUCTFINDINGTYPECD" type="VARCHAR2(12)"/>
			<column name="PRODUCTMNEMONICCD" type="VARCHAR2(50)"/>
			<column name="SUBPRODUCTMNEMONICCD" type="VARCHAR2(50)"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
		</createTable>

		<createTable tableName="CE.MEDICALFINDINGTYPE" schemaName="CE">
			<column name="MEDICALFINDINGTYPEDESC" type="VARCHAR2(255)"/>
			<column name="INSERTEDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="RECORDINSERTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="RECORDUPDTDT" type="TIMESTAMP" defaultValueComputed="CURRENT_TIMESTAMP"/>
			<column name="UPDTDBY" type="VARCHAR2(30)" defaultValue="DEFAULT USER"/>
			<column name="HEALTHSTATEAPPLICABLEFLAG" type="CHAR(1)"/>
			<column name="MEDICALFINDINGTYPECD" type="VARCHAR2(12)">
				<constraints primaryKey="true"/>
			</column>
		</createTable>

		<addNotNullConstraint
			columnName="RECOMMENDATIONTEXTID"
			schemaName="CE"
			columnDataType="NUMBER"
			tableName="RECOMMENDATIONTEXT"/>

		<addNotNullConstraint
			columnName="RECOMMENDATIONID"
			schemaName="CE"
			columnDataType="NUMBER(10,0)"
			tableName="RECOMMENDATIONTEXT"/>

		<addNotNullConstraint
			columnName="LANGUAGECD"
			schemaName="CE"
			columnDataType="CHAR(2)"
			tableName="RECOMMENDATIONTEXT"/>

		<addNotNullConstraint
			columnName="RECOMMENDATIONTEXTTYPE"
			schemaName="CE"
			columnDataType="VARCHAR2(20)"
			tableName="RECOMMENDATIONTEXT"/>

		<addNotNullConstraint
			columnName="MESSAGETYPE"
			schemaName="CE"
			columnDataType="CHAR(3)"
			tableName="RECOMMENDATIONTEXT"/>

		<addNotNullConstraint
			columnName="RECOMMENDATIONSKEY"
			schemaName="CE"
			columnDataType="NUMBER"
			tableName="RECOMMENDATION"/>

		<addNotNullConstraint
			columnName="RECOMMENDATIONID"
			schemaName="CE"
			columnDataType="NUMBER(10,0)"
			tableName="RECOMMENDATION"/>

		<addNotNullConstraint
			columnName="RECOMMENDATIONTYPE"
			schemaName="CE"
			columnDataType="VARCHAR2(20)"
			tableName="RECOMMENDATION"/>

		<addNotNullConstraint
			columnName="CLINICALREVIEWTYPE"
			schemaName="CE"
			columnDataType="VARCHAR2(20)"
			tableName="RECOMMENDATION"/>

		<addNotNullConstraint
			columnName="PRIVACYCATEGORY"
			schemaName="CE"
			columnDataType="VARCHAR2(20)"
			tableName="RECOMMENDATION"/>

		<addNotNullConstraint
			columnName="EFFECTIVESTARTDT"
			schemaName="CE"
			columnDataType="DATE"
			tableName="RECOMMENDATION"/>

	</changeSet>

</databaseChangeLog>
```

### 03_startup_app.sh
Here, we bring up the CECacheServer with docker-compose with the same network as we used to bring up Apache Ignite in, so the CECacheServer can make requests of the database.
<BR/>
Normally, we would do this in the 01_startup.sh script, but we want to seperate out the effects of the database from the application for performance collection purposes, so we do it here.

```bash
#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Startup CECacheServer Locally"
docker volume rm 07_oracle_local_oracle_data
docker-compose -f docker-compose.app.yml up -d --build

echo "Wait For CECacheServer To Start"
while true ; do
  docker logs cecacheserver_fororacle_container > stdout.txt 2> stderr.txt
#  result=$(grep -cE "<<<<< Local Cache Statistics <<<<<" stdout.txt) cecacheserver_formongodb_container is failing!
  result=$(grep -cE "using Agent sizeof engine" stdout.txt)
  if [ $result != 0 ] ; then
    echo "CECacheServer has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Startup CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
```

### 04_shutdown.sh
This script is brutely simple.  It uses docker-compose to bring down the environment it established, and then uses docker volume rm to delete the data which held the bits for out database data.

```bash
#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown Oracle and CECacheServer Locally"
docker-compose -f docker-compose.app.yml down
docker volume rm 07_oracle_local_cecacheserver_data
docker-compose -f docker-compose.yml -f docker-compose.app.yml down
docker volume rm 07_oracle_local_oracle_data
docker volume rm 07_oracle_local_cecacheserver_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results  ${experiment} "07_Oracle_Local: Shutdown Oracle and CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh
```

### Putting it all together...

It all looks something like this:

![01_startup](README_assets/01_startup.png)\
<BR />
![02_populate_01](README_assets/02_populate_01.png)\
![02_populate_02](README_assets/02_populate_02.png)\
![02_populate_03](README_assets/02_populate_03.png)\
![02_populate_04](README_assets/02_populate_04.png)\
<BR />
![03_startup_app](README_assets/03_startup_app.png)\
<BR />
![04_shutdown](README_assets/04_shutdown.png)\
<BR />
And just for laughs, here's the timings for this run.  All kept in a csv file in S3 at s3://health-engine-aws-poc/Experimental Results.csv
![Experimental Results](README_assets/Experimental Results.png)\
<BR />