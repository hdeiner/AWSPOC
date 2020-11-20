#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 200 -f small "Populate Cassandra on AWS"

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Create Cassandra Database (Keyspace) on AWS"
cqlsh localhost 9042 -e "CREATE KEYSPACE IF NOT EXISTS CE WITH replication = {'"'"'class'"'"': '"'"'SimpleStrategy'"'"', '"'"'replication_factor'"'"' : 1}"
figlet -w 200 -f small "Create Cassandra Tables on AWS"
cd /tmp
java -jar liquibase.jar --driver=com.simba.cassandra.jdbc42.Driver --url="jdbc:cassandra://localhost:9042/CE;DefaultKeyspace=CE" --username=cassandra --password=cassandra --classpath="CassandraJDBC42.jar:liquibase-cassandra-4.0.0.2.jar" --changeLogFile=changeset.cassandra.sql --defaultSchemaName=CE update
cd -
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
/tmp/getDataAsCSVline.sh .results "Howard Deiner" "AWS Update Cassanda Schema" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Cassandra Data from S3 Bucket"
cd /tmp
./transfer_from_s3_and_decrypt.sh ce.ClinicalCondition.csv
./transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
./transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
./transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
./transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
./transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
./transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
./transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
./transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
./transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
cd -
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
/tmp/getDataAsCSVline.sh .results "Howard Deiner" "AWS Get Cassandra Data from S3 Bucket" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into Cassandra CSV File For Inport"
cd /tmp
./transform_Oracle_ce.ClinicalCondition_to_csv.sh
./transform_Oracle_ce.DerivedFact_to_csv.sh
./transform_Oracle_ce.DerivedFactProductUsage_to_csv.sh
./transform_Oracle_ce.MedicalFinding_to_csv.sh
./transform_Oracle_ce.MedicalFindingType_to_csv.sh
./transform_Oracle_ce.OpportunityPointsDiscr_to_csv.sh
./transform_Oracle_ce.ProductFinding_to_csv.sh
./transform_Oracle_ce.ProductFindingType_to_csv.sh
./transform_Oracle_ce.ProductOpportunityPoints_to_csv.sh
./transform_Oracle_ce.Recommendation_to_csv.sh
cd -
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
/tmp/getDataAsCSVline.sh .results "Howard Deiner" "AWS Process S3 Data into Cassandra CSV File For Inport" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Load Cassandra Data"
cd /tmp
echo "CE.CLINICAL_CONDITION"
cqlsh -e "COPY CE.CLINICAL_CONDITION (CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FROM '"'"'ce.ClinicalCondition.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACT"
cqlsh -e "COPY CE.DERIVEDFACT (DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.DerivedFact.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh -e "COPY CE.DERIVEDFACTPRODUCTUSAGE (DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.DerivedFactProductUsage.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh -e "COPY CE.DERIVEDFACTPRODUCTUSAGE (DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.DerivedFactProductUsage.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.MEDICALFINDING"
cqlsh -e "COPY CE.MEDICALFINDING (MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FROM '"'"'ce.MedicalFinding.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.MEDICALFINDINGTYPE"
cqlsh -e "COPY CE.MEDICALFINDINGTYPE (MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FROM '"'"'ce.MedicalFindingType.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.OPPORTUNITYPOINTSDISCR"
cqlsh -e "COPY CE.OPPORTUNITYPOINTSDISCR (OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.OpportunityPointsDiscr.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTFINDING"
cqlsh -e "COPY CE.PRODUCTFINDING (PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.ProductFinding.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTFINDINGTYPE"
cqlsh -e "COPY CE.PRODUCTFINDINGTYPE (PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.ProductFindingType.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.PRODUCTOPPORTUNITYPOINTS"
cqlsh -e "COPY CE.PRODUCTOPPORTUNITYPOINTS (OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '"'"'ce.ProductOpportunityPoints.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
echo "CE.RECOMMENDATION"
cqlsh -e "COPY CE.RECOMMENDATION (RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECEDENCEGROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECEDENCERANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FROM '"'"'ce.Recommendation.csv'"'"' WITH DELIMITER='"'"','"'"' AND HEADER=TRUE"
cd -
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
/tmp/getDataAsCSVline.sh .results "Howard Deiner" "AWS Load Cassandra Data" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Test That Cassandra Data Loaded"
echo "CE.CLINICAL_CONDITION"
cqlsh  -e '"'"'select * from CE.CLINICAL_CONDITION LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.CLINICAL_CONDITION;'"'"'
echo "CE.DERIVEDFACT"
cqlsh  -e '"'"'select * from CE.DERIVEDFACT LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.DERIVEDFACT;'"'"'
echo "CE.DERIVEDFACTPRODUCTUSAGE"
cqlsh  -e '"'"'select * from CE.DERIVEDFACTPRODUCTUSAGE LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.DERIVEDFACTPRODUCTUSAGE;'"'"'
echo "CE.MEDICALFINDING"
cqlsh  -e '"'"'select * from CE.MEDICALFINDING LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.MEDICALFINDING;'"'"'
echo "CE.MEDICALFINDINGTYPE"
cqlsh  -e '"'"'select * from CE.MEDICALFINDINGTYPE LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.MEDICALFINDINGTYPE;'"'"'
echo "CE.OPPORTUNITYPOINTSDISCR"
cqlsh  -e '"'"'select * from CE.OPPORTUNITYPOINTSDISCR LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.OPPORTUNITYPOINTSDISCR;'"'"'
echo "CE.PRODUCTFINDING"
cqlsh  -e '"'"'select * from CE.PRODUCTFINDING LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTFINDING;'"'"'
echo "CE.PRODUCTFINDINGTYPE"
cqlsh  -e '"'"'select * from CE.PRODUCTFINDINGTYPE LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTFINDINGTYPE;'"'"'
echo "CE.PRODUCTOPPORTUNITYPOINTS"
cqlsh  -e '"'"'select * from CE.PRODUCTOPPORTUNITYPOINTS LIMIT 2;'"'"'
cqlsh  -e '"'"'select count(*) from CE.PRODUCTOPPORTUNITYPOINTS;'"'"'
echo "CE.RECOMMENDATION"
cqlsh  -e '"'"'select * from CE.RECOMMENDATION WHERE recommendationskey;'"'"'
cqlsh  -e '"'"'select count(*) from CE.RECOMMENDATION;'"'"'
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
/tmp/getDataAsCSVline.sh .results "Howard Deiner" "AWS Test That Cassandra Data Loaded" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv *.csv