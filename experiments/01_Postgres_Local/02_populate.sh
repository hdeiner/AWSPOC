#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Postgres Locally"

figlet -w 240 -f small "Apply Schema for Postgres Locally"

docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -c '"'"'create database CE;'"'"'
docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -d ce -c '"'"'create schema CE;'"'"'
liquibase update
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "01_Postgres_Local: Populate Postgres Schema" >> Experimental\ Results.csv
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
../../getDataAsCSVline.sh .results ${experiment} "01_Postgres_Local: Get Data from S3 Bucket" >> Experimental\ Results.csv
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
../../getDataAsCSVline.sh .results ${experiment} "01_Postgres_Local: Process S3 Data into CSV Files For Import" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Postgres Data"
echo "CLINICAL_CONDITION"
docker cp ce.ClinicalCondition.csv postgres_container:/tmp/ce.ClinicalCondition.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FROM '"'"'/tmp/ce.ClinicalCondition.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "DERIVEDFACT"
docker cp ce.DerivedFact.csv postgres_container:/tmp/ce.DerivedFact.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFact.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "DERIVEDFACTPRODUCTUSAGE"
docker cp ce.DerivedFactProductUsage.csv postgres_container:/tmp/ce.DerivedFactProductUsage.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFactProductUsage.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "MEDICALFINDING"
docker cp ce.MedicalFinding.csv postgres_container:/tmp/ce.MedicalFinding.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FROM '"'"'/tmp/ce.MedicalFinding.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "MEDICALFINDINGTYPE"
docker cp ce.MedicalFindingType.csv postgres_container:/tmp/ce.MedicalFindingType.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FROM '"'"'/tmp/ce.MedicalFindingType.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "OPPORTUNITYPOINTSDISCR"
docker cp ce.OpportunityPointsDiscr.csv postgres_container:/tmp/ce.OpportunityPointsDiscr.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.OpportunityPointsDiscr.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTFINDING"
docker cp ce.ProductFinding.csv postgres_container:/tmp/ce.ProductFinding.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFinding.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTFINDINGTYPE"
docker cp ce.ProductFindingType.csv postgres_container:/tmp/ce.ProductFindingType.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFindingType.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTOPPORTUNITYPOINTS"
docker cp ce.ProductOpportunityPoints.csv postgres_container:/tmp/ce.ProductOpportunityPoints.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductOpportunityPoints.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "RECOMMENDATION"
docker cp ce.Recommendation.csv postgres_container:/tmp/ce.Recommendation.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CE.RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECEDENCEGROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECEDENCERANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FROM '"'"'/tmp/ce.Recommendation.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "01_Postgres_Local: Populate Postgres Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Postgres Data"
echo "CLINICAL_CONDITION"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.CLINICAL_CONDITION limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.CLINICAL_CONDITION;"
echo "DERIVEDFACT"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.DERIVEDFACT limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.DERIVEDFACT;"
echo "DERIVEDFACTPRODUCTUSAGE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.DERIVEDFACTPRODUCTUSAGE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.DERIVEDFACTPRODUCTUSAGE;"
echo "MEDICALFINDING"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.MEDICALFINDING limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.MEDICALFINDING;"
echo "MEDICALFINDINGTYPE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.MEDICALFINDINGTYPE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.MEDICALFINDINGTYPE;"
echo "OPPORTUNITYPOINTSDISCR"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.OPPORTUNITYPOINTSDISCR limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.OPPORTUNITYPOINTSDISCR;"
echo "PRODUCTFINDING"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.PRODUCTFINDING limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) CE.from PRODUCTFINDING;"
echo "PRODUCTFINDINGTYPE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.PRODUCTFINDINGTYPE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.PRODUCTFINDINGTYPE;"
echo "PRODUCTOPPORTUNITYPOINTS"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.PRODUCTOPPORTUNITYPOINTS limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.PRODUCTOPPORTUNITYPOINTS;"
echo "RECOMMENDATION"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CE.RECOMMENDATION limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CE.RECOMMENDATION;"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "01_Postgres_Local: Check Postgres Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results *.csv
