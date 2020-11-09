#!/usr/bin/env bash
!
figlet -w 160 -f small "Populate Ignite Schema Locally"
docker cp ../../src/db/changeset.ignite.sql ignite_container:/tmp/ddl.sql
docker exec ignite_container bash -c "./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql"

figlet -w 160 -f small "Populate Ignite Data Locally"
docker cp ../../data/oracle/ce.Clinical_Condition.csv       ignite_container:/tmp/ce.Clinical_Condition.csv
docker cp ../../data/oracle/ce.DerivedFact.csv              ignite_container:/tmp/ce.DerivedFact.csv
docker cp ../../data/oracle/ce.DerivedFactProductUsage.csv  ignite_container:/tmp/ce.DerivedFactProductUsage.csv
docker cp ../../data/oracle/ce.MedicalFinding.csv           ignite_container:/tmp/ce.MedicalFinding.csv
docker cp ../../data/oracle/ce.MedicalFindingType.csv       ignite_container:/tmp/ce.MedicalFindingType.csv
docker cp ../../data/oracle/ce.OpportunityPointsDiscr.csv   ignite_container:/tmp/ce.OpportunityPointsDiscr.csv
docker cp ../../data/oracle/ce.ProductFinding.csv           ignite_container:/tmp/ce.ProductFinding.csv
docker cp ../../data/oracle/ce.ProductFindingType.csv       ignite_container:/tmp/ce.ProductFindingType.csv
docker cp ../../data/oracle/ce.ProductOpportunityPoints.csv ignite_container:/tmp/ce.ProductOpportunityPoints.csv
docker cp ../../data/oracle/ce.Recommendation.csv           ignite_container:/tmp/ce.Recommendation.csv

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.Clinical_Condition.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.Clinical_Condition.csv\'' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.DerivedFact.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.DerivedFact.csv\'' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID ) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.DerivedFactProductUsage.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.DerivedFactProductUsage.csv\'' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -ir 's/ *|/|/g' /tmp/ce.MedicalFinding.csv"   # remove blanks before |
docker exec ignite_container bash -c "sed -ir 's/| */|/g' /tmp/ce.MedicalFinding.csv"   # remove blanks after |
docker exec ignite_container bash -c "sed -ir 's/^ *//g' /tmp/ce.MedicalFinding.csv"    # remove beining of line blanks
# some of the input fields have commas - must properly make them suitable for csv import
docker exec ignite_container bash -c "sed -i 's/,/:/g' /tmp/ce.MedicalFinding.csv"      # change commas to colons
docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.MedicalFinding.csv"      # change bars to commas
# NOT PULLING IN ALL FIELDS!!
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.MedicalFinding.csv\'' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.MedicalFindingType.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.MedicalFindingType.csv\'' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.OpportunityPointsDiscr.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.OpportunityPointsDiscr.csv\'' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.ProductFinding.csv"
# NOT PULLING IN ALL FIELDS!!
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.ProductFinding.csv\'' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.ProductFindingType.csv"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.ProductFindingType.csv\'' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.ProductOpportunityPoints.csv"
# NOT PULLING IN ALL FIELDS!!
#docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.ProductOpportunityPoints.csv\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.ProductOpportunityPoints.csv\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

docker exec ignite_container bash -c "sed -ir 's/ *|/|/g' /tmp/ce.Recommendation.csv"   # remove blanks before |
docker exec ignite_container bash -c "sed -ir 's/| */|/g' /tmp/ce.Recommendation.csv"   # remove blanks after |
docker exec ignite_container bash -c "sed -ir 's/^ *//g' /tmp/ce.Recommendation.csv"    # remove beining of line blanks
# some of the input fields have commas - must properly make them suitable for csv import
docker exec ignite_container bash -c "sed -i 's/,/:/g' /tmp/ce.Recommendation.csv"      # change commas to colons
docker exec ignite_container bash -c "sed -i 's/|/,/g' /tmp/ce.Recommendation.csv"      # change bars to commas
# NOT PULLING IN ANY FIELDS!!
#docker exec ignite_container bash -c "echo 'COPY FROM '\'/tmp/ce.Recommendation.csv\'' INTO SQL_CE_RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECE_ENCE_ROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECE_ENCE_ANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FORMAT CSV;' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"

figlet -w 160 -f small "Check Ignite Data Locally"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo 'SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
