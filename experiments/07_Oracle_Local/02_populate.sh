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