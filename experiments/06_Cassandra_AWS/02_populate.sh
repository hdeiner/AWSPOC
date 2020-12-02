#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Populate Cassandra AWS"

figlet -w 240 -f small "Apply Schema for Cassanda AWS"
cqlsh localhost 9042 -e "CREATE KEYSPACE IF NOT EXISTS CE WITH replication = {'"'"'class'"'"': '"'"'SimpleStrategy'"'"', '"'"'replication_factor'"'"' : 1}"
cd /tmp
java -jar liquibase.jar --driver=com.simba.cassandra.jdbc42.Driver --url="jdbc:cassandra://localhost:9042/CE;DefaultKeyspace=CE" --username=cassandra --password=cassandra --classpath="CassandraJDBC42.jar:liquibase-cassandra-4.0.0.2.jar" --changeLogFile=changeSet.cassandra.sql --defaultSchemaName=CE update
cd -
EOF'
chmod +x .script
command time -v ./.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassandra_AWS: Populate Cassandra Schema "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
cd /tmp
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
cd -
EOF'
chmod +x .script
command time -v ./.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassanda_AWS: Get Data from S3 Bucket "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into CSV Files For Import"
cd /tmp
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
cd -
EOF'
chmod +x .script
command time -v ./.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassanda_AWS: Process S3 Data into CSV Files For Import "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Cassanda Data"
cd /tmp
echo "CE.CLINICAL_CONDITION"
cqlsh -e "COPY CE.CLINICAL_CONDITION (CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FROM '"'"'ce.ClinicalCondition.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACT"
cqlsh -e "COPY CE.DERIVEDFACT (DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFact.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh -e "COPY CE.DERIVEDFACTPRODUCTUSAGE (DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFactProductUsage.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh -e "COPY CE.DERIVEDFACTPRODUCTUSAGE (DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.DerivedFactProductUsage.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.MEDICALFINDING"
cqlsh -e "COPY CE.MEDICALFINDING (MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FROM '"'"'/tmp/ce.MedicalFinding.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.MEDICALFINDINGTYPE"
cqlsh -e "COPY CE.MEDICALFINDINGTYPE (MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FROM '"'"'/tmp/ce.MedicalFindingType.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.OPPORTUNITYPOINTSDISCR"
cqlsh -e "COPY CE.OPPORTUNITYPOINTSDISCR (OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.OpportunityPointsDiscr.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTFINDING"
cqlsh -e "COPY CE.PRODUCTFINDING (PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFinding.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTFINDINGTYPE"
cqlsh -e "COPY CE.PRODUCTFINDINGTYPE (PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductFindingType.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTOPPORTUNITYPOINTS"
cqlsh -e "COPY CE.PRODUCTOPPORTUNITYPOINTS (OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'/tmp/ce.ProductOpportunityPoints.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.RECOMMENDATION"
cqlsh -e "COPY CE.RECOMMENDATION (RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECEDENCEGROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECEDENCERANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FROM '"'"'/tmp/ce.Recommendation.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
cd -
EOF'
chmod +x .script
command time -v ./.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassanda_AWS: Populate Cassanda Data "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Cassanda Data"
echo "CE.CLINICAL_CONDITION"
cqlsh  -e '"'"'select * from CE.CLINICAL_CONDITION LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.CLINICAL_CONDITION;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.DERIVEDFACT"
cqlsh  -e '"'"'select * from CE.DERIVEDFACT LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.DERIVEDFACT;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh  -e '"'"'select * from CE.DERIVEDFACTPRODUCTUSAGE LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.DERIVEDFACTPRODUCTUSAGE;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.MEDICALFINDING"
cqlsh  -e '"'"'select * from CE.MEDICALFINDING LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.MEDICALFINDING;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.MEDICALFINDINGTYPE"
cqlsh  -e '"'"'select * from CE.MEDICALFINDINGTYPE LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.MEDICALFINDINGTYPE;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.OPPORTUNITYPOINTSDISCR"
cqlsh  -e '"'"'select * from CE.OPPORTUNITYPOINTSDISCR LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.OPPORTUNITYPOINTSDISCR;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.PRODUCTFINDING"
cqlsh  -e '"'"'select * from CE.PRODUCTFINDING LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTFINDING;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.PRODUCTFINDINGTYPE"
cqlsh  -e '"'"'select * from CE.PRODUCTFINDINGTYPE LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTFINDINGTYPE;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.PRODUCTOPPORTUNITYPOINTS"
cqlsh  -e '"'"'select * from CE.PRODUCTOPPORTUNITYPOINTS LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTOPPORTUNITYPOINTS;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
echo "CE.RECOMMENDATION"
cqlsh  -e '"'"'select * from CE.RECOMMENDATION LIMIT 2;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
cqlsh  -e '"'"'select count(*) from CE.RECOMMENDATION;'"'"' | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/Warnings \:|Aggregation query used without partition key|\(see tombstone_warn_threshold\)|yyy|^$/d'"'"'
EOF'
chmod +x .script
command time -v ./.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassanda_AWS: Check Cassanda Data "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script /tmp/.results Experimental\ Results.csv /tmp/*.csv