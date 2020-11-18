#!/usr/bin/env bash

sleep 2m
figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 200 -f small "Populate Oracle AWS"
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended 's/schemaName\=\"CE\"//g' /tmp/changeSet.xml
# modify the tablenames in constraints clauses to include the CE in from of the tablemame.
sed --in-place --regexp-extended 's/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1CE.\2\3/g' /tmp/changeSet.xml
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cd /tmp ; java -jar liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@localhost:1521:ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc8.jar" --changeLogFile=changeSet.xml update'

figlet -w 160 -f small "Get Data from S3 Bucket"
/tmp/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv

figlet -w 160 -f small "Populate Oracle AWS"
touch /tmp/control.ctl ; chmod 666 /tmp/control.ctl
touch /tmp/control.log ; chmod 666 /tmp/control.log
touch /tmp/command.sql ; chmod 666 /tmp/command.sql

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
tr -d $'\r' <ce.Clinical_Condition.csv > /tmp/ce.Clinical_Condition.csv.mod
chmod 666 /tmp/ce.Clinical_Condition.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.Clinical_Condition.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.CLINICAL_CONDITION"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( CLINICAL_CONDITION_COD,' >> /tmp/control.ctl
echo '  CLINICAL_CONDITION_NAM,' >> /tmp/control.ctl
echo '  INSERTED_BY,' >> /tmp/control.ctl
echo '  REC_INSERT_DATE DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  REC_UPD_DATE DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDATED_BY,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONCLASSCD,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONTYPECD,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONABBREV) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.DerivedFact.csv > /tmp/ce.DerivedFact.csv.mod
chmod 666 /tmp/ce.DerivedFact.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.DerivedFact.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.DERIVEDFACT"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( DERIVEDFACTID,' >> /tmp/control.ctl
echo '  DERIVEDFACTTRACKINGID,' >> /tmp/control.ctl
echo '  DERIVEDFACTTYPEID,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.DerivedFactProductUsage.csv > /tmp/ce.DerivedFactProductUsage.csv.mod
chmod 666 /tmp/ce.DerivedFactProductUsage.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.DerivedFactProductUsage.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.DERIVEDFACTPRODUCTUSAGE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( DERIVEDFACTPRODUCTUSAGEID,' >> /tmp/control.ctl
echo '  DERIVEDFACTID,' >> /tmp/control.ctl
echo '  PRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.MedicalFinding.csv > /tmp/ce.MedicalFinding.csv.mod
chmod 666 /tmp/ce.MedicalFinding.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.MedicalFinding.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.MEDICALFINDING"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( MEDICALFINDINGID,' >> /tmp/control.ctl
echo '  MEDICALFINDINGTYPECD,' >> /tmp/control.ctl
echo '  MEDICALFINDINGNM,' >> /tmp/control.ctl
echo '  SEVERITYLEVELCD,' >> /tmp/control.ctl
echo '  IMPACTABLEFLG,' >> /tmp/control.ctl
echo '  CLINICAL_CONDITION_COD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  ACTIVEFLG,' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSDISCRCD) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.MedicalFindingType.csv > /tmp/ce.MedicalFindingType.csv.mod
chmod 666 /tmp/ce.MedicalFindingType.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.MedicalFindingType.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.MEDICALFINDINGTYPE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( MEDICALFINDINGTYPECD,' >> /tmp/control.ctl
echo '  MEDICALFINDINGTYPEDESC,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  HEALTHSTATEAPPLICABLEFLAG) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.OpportunityPointsDiscr.csv > /tmp/ce.OpportunityPointsDiscr.csv.mod
chmod 666 /tmp/ce.OpportunityPointsDiscr.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.OpportunityPointsDiscr.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.OPPORTUNITYPOINTSDISCR"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( OPPORTUNITYPOINTSDISCRCD,' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSDISCNM,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.ProductFinding.csv > /tmp/ce.ProductFinding.csv.mod
chmod 666 /tmp/ce.ProductFinding.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductFinding.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTFINDING"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( PRODUCTFINDINGID,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGNM,' >> /tmp/control.ctl
echo '  SEVERITYLEVELCD,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGTYPECD,' >> /tmp/control.ctl
echo '  PRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  SUBPRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.ProductFindingType.csv > /tmp/ce.ProductFindingType.csv.mod
chmod 666 /tmp/ce.ProductFindingType.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductFindingType.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTFINDINGTYPE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( PRODUCTFINDINGTYPECD,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGTYPEDESC,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

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
tr -d $'\r' <ce.ProductOpportunityPoints.csv > /tmp/ce.ProductOpportunityPoints.csv.mod
chmod 666 /tmp/ce.ProductOpportunityPoints.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductOpportunityPoints.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTOPPORTUNITYPOINTS"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( OPPORTUNITYPOINTSDISCCD,' >> /tmp/control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSNBR,' >> /tmp/control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  DERIVEDFACTPRODUCTUSAGEID,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "Recommendation"
# get rid of ^M (return characters)
tr -d $'\r' <ce.Recommendation.csv > ce.Recommendation.csv.mod
# Merge every other line ince.Recommendation together with a comma between them
paste - - - -d'|' <ce.Recommendation.csv.mod > ce.Recommendation.csv
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
cp ce.Recommendation.csv /tmp/ce.Recommendation.csv.mod
chmod 666 /tmp/ce.Recommendation.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.Recommendation.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.RECOMMENDATION"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( RECOMMENDATIONSKEY,' >> /tmp/control.ctl
echo '  RECOMMENDATIONID,' >> /tmp/control.ctl
echo '  RECOMMENDATIONCODE,' >> /tmp/control.ctl
echo '  RECOMMENDATIONDESC,' >> /tmp/control.ctl
echo '  RECOMMENDATIONTYPE,' >> /tmp/control.ctl
echo '  CCTYPE,' >> /tmp/control.ctl
echo '  CLINICALREVIEWTYPE,' >> /tmp/control.ctl
echo '  AGERANGEID,' >> /tmp/control.ctl
echo '  ACTIONCODE,' >> /tmp/control.ctl
echo '  THERAPEUTICCLASS,' >> /tmp/control.ctl
echo '  MDCCODE,' >> /tmp/control.ctl
echo '  MCCCODE,' >> /tmp/control.ctl
echo '  PRIVACYCATEGORY,' >> /tmp/control.ctl
echo '  INTERVENTION,' >> /tmp/control.ctl
echo '  RECOMMENDATIONFAMILYID,' >> /tmp/control.ctl
echo '  RECOMMENDPRECEDENCEGROUPID,' >> /tmp/control.ctl
echo '  INBOUNDCOMMUNICATIONROUTE,' >> /tmp/control.ctl
echo '  SEVERITY,' >> /tmp/control.ctl
echo '  PRIMARYDIAGNOSIS,' >> /tmp/control.ctl
echo '  SECONDARYDIAGNOSIS,' >> /tmp/control.ctl
echo '  ADVERSEEVENT,' >> /tmp/control.ctl
echo '  ICMCONDITIONID,' >> /tmp/control.ctl
echo '  WELLNESSFLAG,' >> /tmp/control.ctl
echo '  VBFELIGIBLEFLAG,' >> /tmp/control.ctl
echo '  COMMUNICATIONRANKING,' >> /tmp/control.ctl
echo '  PRECEDENCERANKING,' >> /tmp/control.ctl
echo '  PATIENTDERIVEDFLAG,' >> /tmp/control.ctl
echo '  LABREQUIREDFLAG,' >> /tmp/control.ctl
echo '  UTILIZATIONTEXTAVAILABLEF,' >> /tmp/control.ctl
echo '  SENSITIVEMESSAGEFLAG,' >> /tmp/control.ctl
echo '  HIGHIMPACTFLAG,' >> /tmp/control.ctl
echo '  ICMLETTERFLAG,' >> /tmp/control.ctl
echo '  REQCLINICIANCLOSINGFLAG,' >> /tmp/control.ctl
echo '  OPSIMPELMENTATIONPHASE,' >> /tmp/control.ctl
echo '  SEASONALFLAG,' >> /tmp/control.ctl
echo '  SEASONALSTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  SEASONALENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  STANDARDRUNFLAG,' >> /tmp/control.ctl
echo '  INTERVENTIONFEEDBACKFAMILYID,' >> /tmp/control.ctl
echo '  CONDITIONFEEDBACKFAMILYID,' >> /tmp/control.ctl
echo '  ASHWELLNESSELIGIBILITYFLAG,' >> /tmp/control.ctl
echo '  HEALTHADVOCACYELIGIBILITYFLAG) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

figlet -w 160 -f small "Check Oracle AWS"
echo 'SET LINESIZE 200;' >>/tmp/command.sql``
echo 'select * from "CE.CLINICAL_CONDITION" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.CLINICAL_CONDITION";' >>/tmp/command.sql``
echo 'select * from "CE.DERIVEDFACT" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.DERIVEDFACT";' >>/tmp/command.sql``
echo 'select * from "CE.DERIVEDFACTPRODUCTUSAGE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.DERIVEDFACTPRODUCTUSAGE";' >>/tmp/command.sql``
echo 'select * from "CE.MEDICALFINDING" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.MEDICALFINDING";' >>/tmp/command.sql``
echo 'select * from "CE.MEDICALFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.MEDICALFINDINGTYPE";' >>/tmp/command.sql``
echo 'select * from "CE.OPPORTUNITYPOINTSDISCR" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.OPPORTUNITYPOINTSDISCR";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTFINDING" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTFINDING";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTFINDINGTYPE";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTOPPORTUNITYPOINTS" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTOPPORTUNITYPOINTS";' >>/tmp/command.sql``
echo 'select * from "CE.RECOMMENDATION" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.RECOMMENDATION";' >>/tmp/command.sql``
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL'

rm /tmp/control.ctl /tmp/control.log /tmp/command.sql /tmp/changeSet.xml /tmp/*.mod *.csv *.mod
