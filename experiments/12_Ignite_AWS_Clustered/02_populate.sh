#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > .instanceName
sed --in-place --regexp-extended 's/ /_/g' .instanceName
result=$(grep -cE 'Ignite_Instance_000' .instanceName)
if [ $result == 1 ]
then
  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate Ignite Schema"
echo "Apply Schema"
./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS_Clustered: Populate Ignite Schema "$(<.instanceName) >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm.script .results Experimental\ Results.csv

  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Get Data from S3 Bucket"
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
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS_Clustered: Get Data from S3 Bucket "$(<.instanceName) >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv

  bash -c 'cat << "EOF" > .script
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
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS_Clustered: Process S3 Data into CSV Files For Import "$(<.instanceName) >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv

  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate Ignite Data"
echo "Clinical_Condition"
sed -i -e "1d" ce.ClinicalCondition.csv
echo "COPY FROM '"'"'ce.ClinicalCondition.csv'"'"' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "DerivedFact"
sed -i -e "1d" ce.DerivedFact.csv
echo "COPY FROM '"'"'ce.DerivedFact.csv'"'"' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "DerivedFactProductUsage"
sed -i -e "1d" ce.DerivedFactProductUsage.csv
echo "COPY FROM '"'"'ce.DerivedFactProductUsage.csv'"'"' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "MedicalFinding"
sed -i -e "1d" ce.MedicalFinding.csv
echo "COPY FROM '"'"'ce.MedicalFinding.csv'"'"' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "MedicalFindingType"
sed -i -e "1d" ce.MedicalFindingType.csv
echo "COPY FROM '"'"'ce.MedicalFindingType.csv'"'"' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "OpportunityPointsDiscr"
sed -i -e "1d" ce.OpportunityPointsDiscr.csv
echo "COPY FROM '"'"'ce.OpportunityPointsDiscr.csv'"'"' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "ProductFinding"
sed -i -e "1d" ce.ProductFinding.csv
echo "COPY FROM '"'"'ce.ProductFinding.csv'"'"' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "ProductFindingType"
sed -i -e "1d" ce.ProductFindingType.csv
echo "COPY FROM '"'"'ce.ProductFindingType.csv'"'"' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "ProductOpportunityPoints"
sed -i -e "1d" ce.ProductOpportunityPoints.csv
echo "COPY FROM '"'"'ce.ProductOpportunityPoints.csv'"'"' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
echo "Recommendation"
sed -i -e "1d" ce.Recommendation.csv
echo "COPY FROM '"'"'ce.Recommendation.csv'"'"' INTO SQL_CE_RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECE_ENCE_ROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECE_ENCE_ANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FORMAT CSV;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results  ${experiment}  "12_Ignite_AWS_Clustered: Populate Ignite Data "$(<.instanceName) >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv

  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Check Ignite Data"
echo "SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo "SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
rm *.csv *.mod
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results  ${experiment} "12_Ignite_AWS_Clustered: Check Ignite Data "$(<.instanceName) >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv
else
  figlet -w 160 -f small "only run on 000 instance"
fi


