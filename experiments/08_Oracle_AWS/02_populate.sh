#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

sleep 1m

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Oracle AWS"

figlet -w 240 -f small "Apply Schema for Oracle AWS"
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended '"'"'s/schemaName\=\"CE\"//g'"'"' /tmp/changeSet.xml
# modify the tablenames in constraints clauses to include the CE in from of the tablemame.
sed --in-place --regexp-extended '"'"'s/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1CE.\2\3/g'"'"' /tmp/changeSet.xml
cd /tmp ; java -jar liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@localhost:1521/ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc8.jar" --changeLogFile=changeSet.xml update
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Populate Oracle Schema "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
/tmp/transfer_from_s3_and_decrypt.sh ce.ClinicalCondition.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Get Data from S3 Bucket "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into CSV Files For Import"
/tmp/transform_Oracle_ce.ClinicalCondition_to_csv.sh
/tmp/transform_Oracle_ce.DerivedFact_to_csv.sh
/tmp/transform_Oracle_ce.DerivedFactProductUsage_to_csv.sh
/tmp/transform_Oracle_ce.MedicalFinding_to_csv.sh
/tmp/transform_Oracle_ce.MedicalFindingType_to_csv.sh
/tmp/transform_Oracle_ce.OpportunityPointsDiscr_to_csv.sh
/tmp/transform_Oracle_ce.ProductFinding_to_csv.sh
/tmp/transform_Oracle_ce.ProductFindingType_to_csv.sh
/tmp/transform_Oracle_ce.ProductOpportunityPoints_to_csv.sh
/tmp/transform_Oracle_ce.Recommendation_to_csv.sh
mv ce.*.csv /tmp/.
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Process S3 Data into CSV Files For Import "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Oracle Data"
touch /tmp/control.ctl ; chmod 666 /tmp/control.ctl
touch /tmp/control.log ; chmod 666 /tmp/control.log
touch /tmp/command.sql ; chmod 666 /tmp/command.sql
echo "ClinicalCondition"
echo '"'"'options  ( skip=1 ) '"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.ClinicalCondition.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.CLINICAL_CONDITION"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( CLINICAL_CONDITION_COD,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICAL_CONDITION_NAM,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTED_BY,'"'"' >> /tmp/control.ctl
echo '"'"'  REC_INSERT_DATE DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  REC_UPD_DATE DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDATED_BY,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICALCONDITIONCLASSCD,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICALCONDITIONTYPECD,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICALCONDITIONABBREV) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "DerivedFact"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.DerivedFact.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.DERIVEDFACT"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( DERIVEDFACTID,'"'"' >> /tmp/control.ctl
echo '"'"'  DERIVEDFACTTRACKINGID,'"'"' >> /tmp/control.ctl
echo '"'"'  DERIVEDFACTTYPEID,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "DerivedFactProductUsage"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.DerivedFactProductUsage.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.DERIVEDFACTPRODUCTUSAGE"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( DERIVEDFACTPRODUCTUSAGEID,'"'"' >> /tmp/control.ctl
echo '"'"'  DERIVEDFACTID,'"'"' >> /tmp/control.ctl
echo '"'"'  PRODUCTMNEMONICCD,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "MedicalFinding"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.MedicalFinding.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.MEDICALFINDING"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( MEDICALFINDINGID,'"'"' >> /tmp/control.ctl
echo '"'"'  MEDICALFINDINGTYPECD,'"'"' >> /tmp/control.ctl
echo '"'"'  MEDICALFINDINGNM,'"'"' >> /tmp/control.ctl
echo '"'"'  SEVERITYLEVELCD,'"'"' >> /tmp/control.ctl
echo '"'"'  IMPACTABLEFLG,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICAL_CONDITION_COD,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  ACTIVEFLG,'"'"' >> /tmp/control.ctl
echo '"'"'  OPPORTUNITYPOINTSDISCRCD) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "MedicalFindingType"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.MedicalFindingType.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.MEDICALFINDINGTYPE"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( MEDICALFINDINGTYPECD,'"'"' >> /tmp/control.ctl
echo '"'"'  MEDICALFINDINGTYPEDESC,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  HEALTHSTATEAPPLICABLEFLAG) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "OpportunityPointsDiscr"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.OpportunityPointsDiscr.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.OPPORTUNITYPOINTSDISCR"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( OPPORTUNITYPOINTSDISCRCD,'"'"' >> /tmp/control.ctl
echo '"'"'  OPPORTUNITYPOINTSDISCNM,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "ProductFinding"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.ProductFinding.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.PRODUCTFINDING"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( PRODUCTFINDINGID,'"'"' >> /tmp/control.ctl
echo '"'"'  PRODUCTFINDINGNM,'"'"' >> /tmp/control.ctl
echo '"'"'  SEVERITYLEVELCD,'"'"' >> /tmp/control.ctl
echo '"'"'  PRODUCTFINDINGTYPECD,'"'"' >> /tmp/control.ctl
echo '"'"'  PRODUCTMNEMONICCD,'"'"' >> /tmp/control.ctl
echo '"'"'  SUBPRODUCTMNEMONICCD,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "ProductFindingType"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.ProductFindingType.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.PRODUCTFINDINGTYPE"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( PRODUCTFINDINGTYPECD,'"'"' >> /tmp/control.ctl
echo '"'"'  PRODUCTFINDINGTYPEDESC,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
#sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@"`hostname`":1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "ProductOpportunityPoints"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.ProductOpportunityPoints.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.PRODUCTOPPORTUNITYPOINTS"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( OPPORTUNITYPOINTSDISCCD,'"'"' >> /tmp/control.ctl
echo '"'"'  EFFECTIVESTARTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  OPPORTUNITYPOINTSNBR,'"'"' >> /tmp/control.ctl
echo '"'"'  EFFECTIVEENDDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  DERIVEDFACTPRODUCTUSAGEID,'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
echo "Recommendation"
echo '"'"'options  ( skip=1 )'"'"' > /tmp/control.ctl
echo '"'"'load data'"'"' >> /tmp/control.ctl
echo '"'"'  infile "/tmp/ce.Recommendation.csv"'"'"' >> /tmp/control.ctl
echo '"'"'  truncate into table "CE.RECOMMENDATION"'"'"' >> /tmp/control.ctl
echo '"'"'fields terminated by ","'"'"' >> /tmp/control.ctl
echo '"'"'( RECOMMENDATIONSKEY,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDATIONID,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDATIONCODE,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDATIONDESC,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDATIONTYPE,'"'"' >> /tmp/control.ctl
echo '"'"'  CCTYPE,'"'"' >> /tmp/control.ctl
echo '"'"'  CLINICALREVIEWTYPE,'"'"' >> /tmp/control.ctl
echo '"'"'  AGERANGEID,'"'"' >> /tmp/control.ctl
echo '"'"'  ACTIONCODE,'"'"' >> /tmp/control.ctl
echo '"'"'  THERAPEUTICCLASS,'"'"' >> /tmp/control.ctl
echo '"'"'  MDCCODE,'"'"' >> /tmp/control.ctl
echo '"'"'  MCCCODE,'"'"' >> /tmp/control.ctl
echo '"'"'  PRIVACYCATEGORY,'"'"' >> /tmp/control.ctl
echo '"'"'  INTERVENTION,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDATIONFAMILYID,'"'"' >> /tmp/control.ctl
echo '"'"'  RECOMMENDPRECEDENCEGROUPID,'"'"' >> /tmp/control.ctl
echo '"'"'  INBOUNDCOMMUNICATIONROUTE,'"'"' >> /tmp/control.ctl
echo '"'"'  SEVERITY,'"'"' >> /tmp/control.ctl
echo '"'"'  PRIMARYDIAGNOSIS,'"'"' >> /tmp/control.ctl
echo '"'"'  SECONDARYDIAGNOSIS,'"'"' >> /tmp/control.ctl
echo '"'"'  ADVERSEEVENT,'"'"' >> /tmp/control.ctl
echo '"'"'  ICMCONDITIONID,'"'"' >> /tmp/control.ctl
echo '"'"'  WELLNESSFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  VBFELIGIBLEFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  COMMUNICATIONRANKING,'"'"' >> /tmp/control.ctl
echo '"'"'  PRECEDENCERANKING,'"'"' >> /tmp/control.ctl
echo '"'"'  PATIENTDERIVEDFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  LABREQUIREDFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  UTILIZATIONTEXTAVAILABLEF,'"'"' >> /tmp/control.ctl
echo '"'"'  SENSITIVEMESSAGEFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  HIGHIMPACTFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  ICMLETTERFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  REQCLINICIANCLOSINGFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  OPSIMPELMENTATIONPHASE,'"'"' >> /tmp/control.ctl
echo '"'"'  SEASONALFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  SEASONALSTARTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  SEASONALENDDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  EFFECTIVESTARTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  EFFECTIVEENDDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDINSERTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  RECORDUPDTDT DATE "YYYY-MM-DD",'"'"' >> /tmp/control.ctl
echo '"'"'  INSERTEDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  UPDTDBY,'"'"' >> /tmp/control.ctl
echo '"'"'  STANDARDRUNFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  INTERVENTIONFEEDBACKFAMILYID,'"'"' >> /tmp/control.ctl
echo '"'"'  CONDITIONFEEDBACKFAMILYID,'"'"' >> /tmp/control.ctl
echo '"'"'  ASHWELLNESSELIGIBILITYFLAG,'"'"' >> /tmp/control.ctl
echo '"'"'  HEALTHADVOCACYELIGIBILITYFLAG) '"'"' >> /tmp/control.ctl
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '"'"'/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"'"'"
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Populate Oracle Data "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Oracle Data"
echo ""
echo "ClinicalCondition"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN CLINICAL_CONDITION_NAM FORMAT A22;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTED_BY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDATED_BY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONDESC FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN CLINICALCONDITIONABBREV FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.CLINICAL_CONDITION" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.CLINICAL_CONDITION";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "DerivedFact"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.DERIVEDFACT" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.DERIVEDFACT";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "DerivedFactProductUsage"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRODUCTMNEMONICCD FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.DERIVEDFACTPRODUCTUSAGE" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.DERIVEDFACTPRODUCTUSAGE";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "MedicalFinding"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN MEDICALFINDINGNM FORMAT A30;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.MEDICALFINDING" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.MEDICALFINDING";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "MedicalFindingType"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN MEDICALFINDINGTYPEDESC FORMAT A30;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.MEDICALFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.MEDICALFINDINGTYPE";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "OppurtunityPointsDiscr"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSDISCNM FORMAT A30;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.OPPORTUNITYPOINTSDISCR" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.OPPORTUNITYPOINTSDISCR";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "ProductFinding"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRODUCTFINDINGNM FORMAT A30;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRODUCTMNEMONICCD FORMAT A20;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN SUBPRODUCTMNEMONICCD FORMAT A20;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.PRODUCTFINDING" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.PRODUCTFINDING";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "ProductFindingType"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRODUCTFINDINGTYPEDESC FORMAT A30;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.PRODUCTFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.PRODUCTFINDINGTYPE";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "ProductOpportunityPoints"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSDISCCD FORMAT A20;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDUPDTDT FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN UPDTDBY FORMAT A12;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.PRODUCTOPPORTUNITYPOINTS" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.PRODUCTOPPORTUNITYPOINTS";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "Recommendation"
echo '"'"'SET LINESIZE 240; '"'"' > /tmp/command.sql
echo '"'"'SET WRAP OFF;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMSPOOL ON;'"'"' >> /tmp/command.sql
echo '"'"'SET TRIMOUT ON;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONSKEY FORMAT 999;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONID FORMAT 999;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONCODE FORMAT A18;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONDESC FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONTYPE FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECOMMENDATIONTYPE FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN CCTYPE FORMAT A20;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN ACTIONCODE FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN MDCCODE FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN MCCCODE FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRIVACYCATEGORY FORMAT A1;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INTERVENTION FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN CLINICALREVIEWTYPE FORMAT A4;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN OPPORTUNITYPOINTSNBR FORMAT 999;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN DERIVEDFACTPRODUCTUSAGEID FORMAT 999999;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN INSERTEDBY FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN PRIMARYDIAGNOSIS FORMAT A10;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN RECORDINSERTDT FORMAT A9;'"'"' >> /tmp/command.sql
echo '"'"'COLUMN THERAPEUTICCLASS FORMAT A16;'"'"' >> /tmp/command.sql
echo '"'"'select * from "CE.RECOMMENDATION" FETCH FIRST 2 ROWS ONLY;'"'"' >> /tmp/command.sql
echo '"'"'select count(*) from "CE.RECOMMENDATION";'"'"' >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
rm /tmp/control.ctl /tmp/control.log /tmp/command.sql /tmp/changeSet.xml /tmp/*.csv
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Check Oracle Data "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results *.csv
