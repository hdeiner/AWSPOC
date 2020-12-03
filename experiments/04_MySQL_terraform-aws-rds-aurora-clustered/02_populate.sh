#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Populate MySQL Clustered on AWS RDS Aurora"
echo `terraform output database_dns | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_dns
echo `terraform output database_port | grep -Eo '"'"'[0-9]{1,}'"'"' | cut -d '"'"'"'"'"' -f2` > .database_port
echo `terraform output database_username | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_username
echo `terraform output database_password | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_password

cp .database_dns .database_name
sed --in-place --regexp-extended '"'"'s/\..*//g'"'"' .database_name

figlet -w 240 -f small "Apply Schema for MySQL AWS RDS Aurora"
docker exec mysql_container echo '"'"'CREATE DATABASE CE;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password)
#docker exec mysql_container echo '"'"'SHOW DATABASES;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password)

cp ../../src/java/Translator/changeSet.xml changeSet.xml
# fix <createTable tableName="CE. to become <createTable tableName="
sed --in-place --regexp-extended '"'"'s/<createTable\ tableName\=\"CE\./<createTable\ tableName\=\"/g'"'"' changeSet.xml

echo '"'"'changeLogFile: changeSet.xml'"'"' > liquibase.properties
echo '"'"'url:  jdbc:mysql://'"'"'$(<.database_dns)'"'"':'"'"'$(<.database_port)'"'"'/CE?autoReconnect=true&verifyServerCertificate=false&useSSL=false'"'"' >> liquibase.properties
echo '"'"'username: '"'"'$(<.database_username) >> liquibase.properties
echo '"'"'password: '"'"'$(<.database_password) >> liquibase.properties
echo '"'"'driver:  org.gjt.mm.mysql.Driver'"'"' >> liquibase.properties
echo '"'"'classpath:  ../../liquibase_drivers/mysql-connector-java-5.1.48.jar'"'"' >> liquibase.properties
liquibase update

EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Populate MySQL Schema "$(<.database_name) >> Experimental\ Results.csv
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
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Get Data from S3 Bucket "$(<.database_name) >> Experimental\ Results.csv
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
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Process S3 Data into CSV Files For Import "$(<.database_name) >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
MYSQL='"'"'mysql -h '"'"'$(<.database_dns)'"'"' -P '"'"'$(<.database_port)'"'"' -u '"'"'$(<.database_username)'"'"' --password='"'"'$(<.database_password)'"'"' --local-infile'"'"'
figlet -w 240 -f small "Populate MySQL Data"
echo "CE.CLINICAL_CONDITION"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.ClinicalCondition.csv" INTO TABLE CE.CLINICAL_CONDITION FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,@CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) SET CLINICALCONDITIONCLASSCD = IF(@CLINICALCONDITIONCLASSCD="",NULL,@CLINICALCONDITIONCLASSCD);'"'"' | $MYSQL
echo "CE.DERIVEDFACT"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.DerivedFact.csv" INTO TABLE CE.DERIVEDFACT FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY);'"'"' | $MYSQL
echo "CE.DERIVEDFACTPRODUCTUSAGE"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.DerivedFactProductUsage.csv" INTO TABLE CE.DERIVEDFACTPRODUCTUSAGE FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY);'"'"' | $MYSQL
echo "CE.MEDICALFINDING"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.MedicalFinding.csv" INTO TABLE CE.MEDICALFINDING FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,@CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) SET CLINICAL_CONDITION_COD = IF(@CLINICAL_CONDITION_COD="",NULL,@CLINICAL_CONDITION_COD);'"'"' | $MYSQL
echo "CE.MEDICALFINDINGTYPE"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.MedicalFindingType.csv" INTO TABLE CE.MEDICALFINDINGTYPE FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG);'"'"' | $MYSQL
echo "CE.OPPORTUNITYPOINTSDISCR"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.OpportunityPointsDiscr.csv" INTO TABLE CE.OPPORTUNITYPOINTSDISCR FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY);'"'"' | $MYSQL
echo "CE.PRODUCTFINDING"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.ProductFinding.csv" INTO TABLE CE.PRODUCTFINDING FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY);'"'"' | $MYSQL
echo "CE.PRODUCTFINDINGTYPE"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.ProductFindingType.csv" INTO TABLE CE.PRODUCTFINDINGTYPE FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY);'"'"' | $MYSQL
echo "CE.PRODUCTOPPORTUNITYPOINTS"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.ProductOpportunityPoints.csv" INTO TABLE CE.PRODUCTOPPORTUNITYPOINTS FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,@EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) SET EFFECTIVEENDDT = IF(@EFFECTIVEENDDT="",NULL,@EFFECTIVEENDDT);'"'"' | $MYSQL
echo "CE.RECOMMENDATION"
docker exec mysql_container echo '"'"'USE CE;LOAD DATA LOCAL INFILE "./ce.Recommendation.csv" INTO TABLE CE.RECOMMENDATION FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" IGNORE 1 ROWS (RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,@AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,@RECOMMENDATIONFAMILYID,@RECOMMENDPRECEDENCEGROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,@ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,@COMMUNICATIONRANKING,@PRECEDENCERANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,@OPSIMPELMENTATIONPHASE,SEASONALFLAG,@SEASONALSTARTDT,@SEASONALENDDT,EFFECTIVESTARTDT,@EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,@INTERVENTIONFEEDBACKFAMILYID,@CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) SET RECOMMENDATIONFAMILYID = IF(@RECOMMENDATIONFAMILYID="",NULL,@RECOMMENDATIONFAMILYID), RECOMMENDPRECEDENCEGROUPID = IF(@RECOMMENDPRECEDENCEGROUPID="",NULL,@RECOMMENDPRECEDENCEGROUPID), ICMCONDITIONID = IF(@ICMCONDITIONID="",NULL,@ICMCONDITIONID), COMMUNICATIONRANKING = IF(@COMMUNICATIONRANKING="",NULL,@COMMUNICATIONRANKING), PRECEDENCERANKING = IF(@PRECEDENCERANKING="",NULL,@PRECEDENCERANKING), OPSIMPELMENTATIONPHASE = IF(@OPSIMPELMENTATIONPHASE="",NULL,@OPSIMPELMENTATIONPHASE), SEASONALSTARTDT = IF(@SEASONALSTARTDT="",NULL,@SEASONALSTARTDT), SEASONALENDDT = IF(@SEASONALENDDT="",NULL,@SEASONALENDDT), EFFECTIVEENDDT = IF(@EFFECTIVEENDDT="",NULL,@EFFECTIVEENDDT), INTERVENTIONFEEDBACKFAMILYID = IF(@INTERVENTIONFEEDBACKFAMILYID="",NULL,@INTERVENTIONFEEDBACKFAMILYID), CONDITIONFEEDBACKFAMILYID = IF(@CONDITIONFEEDBACKFAMILYID="",NULL,@CONDITIONFEEDBACKFAMILYID), AGERANGEID = IF(@AGERANGEID="",NULL,@AGERANGEID);'"'"' | $MYSQL
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Populate MySQL Data "$(<.database_name) >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Check MySQL Data"
echo "CE.CLINICAL_CONDITION"
docker exec mysql_container echo '"'"'select * from CE.CLINICAL_CONDITION LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.CLINICAL_CONDITION;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.DERIVEDFACT"
docker exec mysql_container echo '"'"'select * from CE.DERIVEDFACT LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.DERIVEDFACT;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.DERIVEDFACTPRODUCTUSAGE"
docker exec mysql_container echo '"'"'select * from CE.DERIVEDFACTPRODUCTUSAGE LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.DERIVEDFACTPRODUCTUSAGE;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.MEDICALFINDING"
docker exec mysql_container echo '"'"'select * from CE.MEDICALFINDING LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.MEDICALFINDING;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.MEDICALFINDINGTYPE"
docker exec mysql_container echo '"'"'select * from CE.MEDICALFINDINGTYPE LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.MEDICALFINDINGTYPE;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.OPPORTUNITYPOINTSDISCR"
docker exec mysql_container echo '"'"'select * from CE.OPPORTUNITYPOINTSDISCR LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.OPPORTUNITYPOINTSDISCR;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.PRODUCTFINDING"
docker exec mysql_container echo '"'"'select * from CE.PRODUCTFINDING LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.PRODUCTFINDING;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.PRODUCTFINDINGTYPE"
docker exec mysql_container echo '"'"'select * from CE.PRODUCTFINDINGTYPE LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.PRODUCTFINDINGTYPE;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.PRODUCTOPPORTUNITYPOINTS"
docker exec mysql_container echo '"'"'select * from CE.PRODUCTOPPORTUNITYPOINTS LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.PRODUCTOPPORTUNITYPOINTS;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
echo "CE.RECOMMENDATION"
docker exec mysql_container echo '"'"'select * from CE.RECOMMENDATION LIMIT 2;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
docker exec mysql_container echo '"'"'select count(*) from CE.RECOMMENDATION;'"'"' | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) CE
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Check MySQL Data "$(<.database_name) >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

rm .database_dns .database_port .database_username .database_password .database_name liquibase.properties changeSet.xml ce.*.csv