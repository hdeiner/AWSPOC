#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate Ignite Schema Locally"
# issues with thingg like VARCHAR needing to be VARCHAR(12) docker cp ../../src/java/IgniteTranslator/changeSet.ignite.sql ignite_container:/tmp/ddl.sql
docker cp ../../src/db/changeset.ignite.sql ignite_container:/tmp/ddl.sql
docker exec ignite_container bash -c "./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Populate Ignite Schema Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Get Data from S3 Bucket"
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
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Get Data from S3 Bucket" >> Experimental\ Results.csv
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
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Process S3 Data into CSV Files For Import" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate Ignite Data Locally"
echo "Clinical_Condition"
sed -i -e "1d" ce.ClinicalCondition.csv
docker cp ce.ClinicalCondition.csv ignite_container:/tmp/ce.ClinicalCondition.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.ClinicalCondition.csv\'"'"''"'"' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "DerivedFact"
sed -i -e "1d" ce.DerivedFact.csv
docker cp ce.DerivedFact.csv ignite_container:/tmp/ce.DerivedFact.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.DerivedFact.csv\'"'"''"'"' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "DerivedFactProductUsage"
sed -i -e "1d" ce.DerivedFactProductUsage.csv
docker cp ce.DerivedFactProductUsage.csv ignite_container:/tmp/ce.DerivedFactProductUsage.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.DerivedFactProductUsage.csv\'"'"''"'"' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "MedicalFinding"
sed -i -e "1d" ce.MedicalFinding.csv
docker cp ce.MedicalFinding.csv ignite_container:/tmp/ce.MedicalFinding.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.MedicalFinding.csv\'"'"''"'"' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "MedicalFindingType"
sed -i -e "1d" ce.MedicalFindingType.csv
docker cp ce.MedicalFindingType.csv ignite_container:/tmp/ce.MedicalFindingType.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.MedicalFindingType.csv\'"'"''"'"' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "OpportunityPointsDiscr"
sed -i -e "1d" ce.OpportunityPointsDiscr.csv
docker cp ce.OpportunityPointsDiscr.csv ignite_container:/tmp/ce.OpportunityPointsDiscr.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.OpportunityPointsDiscr.csv\'"'"''"'"' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "ProductFinding"
sed -i -e "1d" ce.ProductFinding.csv
docker cp ce.ProductFinding.csv ignite_container:/tmp/ce.ProductFinding.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.ProductFinding.csv\'"'"''"'"' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "ProductFindingType"
sed -i -e "1d" ce.ProductFindingType.csv
docker cp ce.ProductFindingType.csv ignite_container:/tmp/ce.ProductFindingType.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.ProductFindingType.csv\'"'"''"'"' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "ProductOpportunityPoints"
sed -i -e "1d" ce.ProductOpportunityPoints.csv
docker cp ce.ProductOpportunityPoints.csv ignite_container:/tmp/ce.ProductOpportunityPoints.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.ProductOpportunityPoints.csv\'"'"''"'"' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
echo "Recommendation"
sed -i -e "1d" ce.Recommendation.csv
docker cp ce.Recommendation.csv ignite_container:/tmp/ce.Recommendation.csv
docker exec ignite_container bash -c "echo '"'"'COPY FROM '"'"'\'"'"'/tmp/ce.Recommendation.csv\'"'"''"'"' INTO SQL_CE_RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECE_ENCE_ROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECE_ENCE_ANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FORMAT CSV;'"'"' | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Populate Ignite Data Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Check Ignite Data Locally"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
docker exec ignite_container bash -c "echo '"'"'SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;'"'"' | ./apache-ignite/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Check Ignite Data Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results *.csv