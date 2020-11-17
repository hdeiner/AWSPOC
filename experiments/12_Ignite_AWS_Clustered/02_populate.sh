#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > .instanceName
result=$(grep -cE 'Ignite Instance 000' .instanceName)
if [ $result == 1 ]
then
  figlet -w 160 -f small "Populate Ignite Schema AWS Cluster"

  echo "Apply Schema"
  ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql

  echo "Import ce.Clinical_Condition.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
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
  echo 'COPY FROM '\'ce.Clinical_Condition.csv.mod\'' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.DerivedFact.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
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
  echo 'COPY FROM '\'ce.DerivedFact.csv.mod\'' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.DerivedFactProductUsage.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
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
  echo 'COPY FROM '\'ce.DerivedFactProductUsage.csv.mod\'' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.MedicalFinding.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
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
  echo 'COPY FROM '\'ce.MedicalFinding.csv.mod\'' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.MedicalFindingType.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
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
  echo 'COPY FROM '\'ce.MedicalFindingType.csv.mod\'' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.ProductFinding.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
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
  echo 'COPY FROM '\'ce.ProductFinding.csv.mod\'' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.ProductFindingType.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
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
  echo 'COPY FROM '\'ce.ProductFindingType.csv.mod\'' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.OpportunityPointsDiscr.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
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
  echo 'COPY FROM '\'ce.OpportunityPointsDiscr.csv.mod\'' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.ProductOpportunityPoints.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
  # convert comas to semi-colons
  sed --in-place --regexp-extended 's/,/;/g' ce.ProductOpportunityPoints.csv
  # convert bars to commas
  sed --in-place 's/|/,/g' ce.ProductOpportunityPoints.csv
  # get rid of timestamps and decimals after timestamp
  sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductOpportunityPoints.csv
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
  echo 'COPY FROM '\'ce.ProductOpportunityPoints.csv.mod\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.Recommendation.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
# get rid of ^M (return characters)
  tr -d $'\r' < ce.Recommendation.csv > ce.Recommendation.csv.mod
  # Merge every other line in ce.Recommendation together with a comma between them
  paste - - - -d'|' < ce.Recommendation.csv.mod > ce.Recommendation.csv
  # convert comas to semi-colons
  sed --in-place --regexp-extended 's/,/;/g' ce.Recommendation.csv
  # convert bars to commas
  sed --in-place 's/|/,/g' ce.Recommendation.csv
  # get rid of timestamps and decimals after timestamp
  sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.Recommendation.csv
  # remove blanks at start of line
  sed --in-place --regexp-extended 's/^ *//g' ce.Recommendation.csv
  # remove blanks before commas
  sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Recommendation.csv
  # remove blanks after commas
  sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Recommendation.csv
  # remove blanks at end of line
  sed --in-place --regexp-extended 's/ *$//g' ce.Recommendation.csv
  echo 'COPY FROM '\'ce.Recommendation.csv\'' INTO SQL_CE_RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECE_ENCE_ROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECE_ENCE_ANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  figlet -w 160 -f small "Check Ignite AWS Cluster"
  echo 'SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  rm *.csv *.mod
else
  figlet -w 160 -f small "only run on 000 instance"
fi


