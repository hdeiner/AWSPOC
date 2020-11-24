#!/usr/bin/env bash
bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Postgres Locally"
docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -c '"'"'create database CE;'"'"'
cp ../../src/java/Translator/changeSet.xml changeSet.xml
# fix <createTable tableName=" to become <createTable tableName="
sed --in-place --regexp-extended '"'"'s/<createTable\ tableName\=\"CE\./<createTable\ tableName\=\"/g'"'"' changeSet.xml
# fix to remove " schemaName="CE""
sed --in-place --regexp-extended '"'"'s/ schemaName\=\"\CE\">/>/g'"'"' changeSet.xml
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended '"'"'s/schemaName\=\"CE\"//g'"'"' changeSet.xml
liquibase update
rm changeSet.xml
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Update Postgres Schema" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Postgres Data from S3 Bucket"
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
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Get Postgres Data from S3 Bucket" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into Postgres CSV File For Import"
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
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Process S3 Data into Postgres CSV File For Import" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Load Postgres Data"
echo "CLINICAL_CONDITION"
docker cp ce.ClinicalCondition.csv postgres_container:/tmp/ce.ClinicalCondition.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FROM '"'"'/tmp/ce.ClinicalCondition.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "DERIVEDFACT"
docker cp ce.DerivedFact.csv postgres_container:/tmp/ce.DerivedFact.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFact.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "DERIVEDFACTPRODUCTUSAGE"
docker cp ce.DerivedFactProductUsage.csv postgres_container:/tmp/ce.DerivedFactProductUsage.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFactProductUsage.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "MEDICALFINDING"
docker cp ce.MedicalFinding.csv postgres_container:/tmp/ce.MedicalFinding.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY MEDICALFINDING(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FROM '"'"'/tmp/ce.MedicalFinding.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "MEDICALFINDINGTYPE"
docker cp ce.MedicalFindingType.csv postgres_container:/tmp/ce.MedicalFindingType.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FROM '"'"'/tmp/ce.MedicalFindingType.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "OPPORTUNITYPOINTSDISCR"
docker cp ce.OpportunityPointsDiscr.csv postgres_container:/tmp/ce.OpportunityPointsDiscr.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.OpportunityPointsDiscr.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTFINDING"
docker cp ce.ProductFinding.csv postgres_container:/tmp/ce.ProductFinding.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFinding.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTFINDINGTYPE"
docker cp ce.ProductFindingType.csv postgres_container:/tmp/ce.ProductFindingType.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFindingType.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "PRODUCTOPPORTUNITYPOINTS"
docker cp ce.ProductOpportunityPoints.csv postgres_container:/tmp/ce.ProductOpportunityPoints.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductOpportunityPoints.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
echo "RECOMMENDATION"
docker cp ce.Recommendation.csv postgres_container:/tmp/ce.Recommendation.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "COPY RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECEDENCEGROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECEDENCERANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FROM '"'"'/tmp/ce.Recommendation.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Load Postgres Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Postgres Locally"
echo "CLINICAL_CONDITION"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from CLINICAL_CONDITION limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from CLINICAL_CONDITION;"
echo "DERIVEDFACT"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from DERIVEDFACT limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from DERIVEDFACT;"
echo "DERIVEDFACTPRODUCTUSAGE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from DERIVEDFACTPRODUCTUSAGE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from DERIVEDFACTPRODUCTUSAGE;"
echo "MEDICALFINDING"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from MEDICALFINDING limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from MEDICALFINDING;"
echo "MEDICALFINDINGTYPE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from MEDICALFINDINGTYPE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from MEDICALFINDINGTYPE;"
echo "OPPORTUNITYPOINTSDISCR"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from OPPORTUNITYPOINTSDISCR limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from OPPORTUNITYPOINTSDISCR;"
echo "PRODUCTFINDING"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from PRODUCTFINDING limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from PRODUCTFINDING;"
echo "PRODUCTFINDINGTYPE"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from PRODUCTFINDINGTYPE limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from PRODUCTFINDINGTYPE;"
echo "PRODUCTOPPORTUNITYPOINTS"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from PRODUCTOPPORTUNITYPOINTS limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from PRODUCTOPPORTUNITYPOINTS;"
echo "RECOMMENDATION"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select * from RECOMMENDATION limit 2;"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d ce --no-align -c "select count(*) from RECOMMENDATION;"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Test That Postgres Data Loaded" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results *.csv
