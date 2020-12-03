### Starting out with AWS RDS MySQL Clusters

##### Concept

> Amazon Relational Database Service (or Amazon RDS) is a distributed relational database service by Amazon Web Services (AWS). It is a web service running "in the cloud" designed to simplify the setup, operation, and scaling of a relational database for use in applications. Administration processes like patching the database software, backing up databases and enabling point-in-time recovery are managed automatically. Scaling storage and compute resources can be performed by a single API call as AWS does not offer an ssh connection to RDS instances
>
> https://en.wikipedia.org/wiki/Amazon_Relational_Database_Service
>
> MySQL is the world's most popular open source relational database and Amazon RDS makes it easy to set up, operate, and scale MySQL deployments in the cloud. With Amazon RDS, you can deploy scalable MySQL servers in minutes with cost-efficient and resizable hardware capacity.
>  
> Amazon RDS for MySQL frees you up to focus on application development by managing time-consuming database administration tasks including backups, software patching, monitoring, scaling and replication.
> 
> Amazon RDS supports MySQL Community Edition versions 5.5, 5.6, 5.7, and 8.0 which means that the code, applications, and tools you already use today can be used with Amazon RDS.>
>
> https://aws.amazon.com/rds/mysql/ (AWS propoganda)
>
#### Execution

### 01_startup.sh
This script uses simple Terraform and applies it.  You get 14 resources of ready to go database.  We also bring up a Local MySQL docker-composed instance, se we don't have to install MySQL on our machine to speak to the database in AWS, 
```bash
#!/usr/bin/env bash

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Startup MySQL AWS Cluster"
terraform init
terraform apply -auto-approve
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Startup MySQL AWS Cluster" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Startup MySQL/MySQLClient Locally"
docker volume rm 03_mysql_local_mysql_data
docker volume rm 03_mysql_local_mysqlclient_data
docker-compose -f ../03_MySQL_Local/docker-compose.yml up -d
figlet -w 160 -f small "Wait For MySQL To Start"
while true ; do
  docker logs mysql_container > stdout.txt 2> stderr.txt
  result=$(grep -c "\[System\] \[MY-010931\] \[Server\] /usr/sbin/mysqld: ready for connections." stderr.txt)
  if [ $result = 1 ] ; then
    sleep 10 # it says it'"'"'s ready for connections, but not really
    echo "MySQL has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Startup MySQL Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
```
The one script that does all of the heavy lifting is below.
```hcl-terraform
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}

#######################################
# Data sources to get VPC and subnets #
#######################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

##############
# RDS Aurora #
##############
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"

  name                            = "mysql-aurora-clustered"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7"
  username                        = "root"
  password                        = "password"
  publicly_accessible             = true
  subnets                         = data.aws_subnet_ids.all.ids
  vpc_id                          = data.aws_vpc.default.id
  allowed_security_groups         = [aws_security_group.aurora_connect.id]
  allowed_cidr_blocks             = ["0.0.0.0/0"]
  replica_count                   = 2
  instance_type                   = "db.r4.large" #  2 vCPU	8 ECU 15.25 GiB Memory EBS Only	$0.133 per Hour
  instance_type_replica           = "db.t3.medium" # 2 vCPU	variable ECU 4 GiB Memory EBS Only	$0.0416 per Hour
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_mysql57_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_mysql57_parameter_group.id
  #  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  security_group_description      = ""
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_db_parameter_group" "aurora_db_mysql57_parameter_group" {
  name        = "test-aurora-db-mysql57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-db-mysql57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_mysql57_parameter_group" {
  name        = "test-aurora-mysql57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-mysql57-cluster-parameter-group"
}

#############################
# Example of security group #
#############################
resource "aws_security_group" "app_servers" {
  name_prefix = "app-servers-"
  description = "For application servers"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_servers.id
  security_group_id        = module.aurora.this_security_group_id
}

resource "aws_security_group" "aurora_connect" {
  name        = "Aurora Security Group"
  description = "Aurora Security Group"
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "Aurora Security Group"
  }
}
```

This is what the console looks like when the script is executed.
![01_startup_console_01](README_assets/01_startup_console_01.png)\
![01_startup_console_02](README_assets/01_startup_console_02.png)\
![01_startup_console_03](README_assets/01_startup_console_03.png)\
![01_startup_console_04](README_assets/01_startup_console_04.png)\
<BR/>
If we were to peruse the AWS Console Database Dashboard, here's what we will see.
![01_startup_aws_console__rds_dashboard_01](README_assets/01_startup_aws_console__rds_dashboard_01.png)\
<BR/>
Looking deeper into the AWS Console Database Connectivity, we'd see this.
![01_startup_aws_console_rds_database_connectivity_01](README_assets/01_startup_aws_console_rds_database_connectivity_01.png)\
<BR/>
And, finally, looking deeper into the AWS Console Database Monitoring, we'd see this.
![01_startup_aws_console_rds_database_monitoring_01](README_assets/01_startup_aws_console_rds_database_monitoring_01.png)\
<BR/>
### 02_populate.sh
This script first uses the running AWS database and to runs mysql in the local docker instance to create a database on AWS for us.

The script then creates a liquibase.properties to run liquibase to update the database to it's intended state.

The script then downloads, decrypts, and processes the S3 files that hold the database data.

And, finally, the script then demonstrates that database has the tables we created and has their data in them, done through IaC.
```bash
#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Populate MySQL Clustered on AWS RDS Aurora"
echo `terraform output database_dns | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_dns
echo `terraform output database_port | grep -Eo '"'"'[0-9]{1,}'"'"' | cut -d '"'"'"'"'"' -f2` > .database_port
echo `terraform output database_username | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_username
echo `terraform output database_password | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_password

cp .database_dns .database_name
sed --in-place --regexp-extended '"'"'s/\..*//g'"'"' .database_name  # take away everything starting with the first dot on the dns name and make it the database name

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
```
This is what the console looks like when the script is executed.
![02_populate_console_01](README_assets/02_populate_console_01.png)\
![02_populate_console_02](README_assets/02_populate_console_02.png)\
![02_populate_console_03](README_assets/02_populate_console_03.png)\
<BR/>
### 03_shutdown.sh
This script is extremely simple.  It tells terraform to destroy all that it created.

```bash
#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Shutdown MySQL Clustered on AWS RDS Aurora"
terraform destroy -auto-approve
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Shutdown MySQL AWS Cluster" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown MySQL/MySQLClient Locally"
docker-compose -f ../03_MySQL_Local/docker-compose.yml down
docker volume rm 03_mysql_local_mysql_data
docker volume rm 03_mysql_local_mysqlclient_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "04_MySQL_AWS_Clustered: Shutdown MySQL Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh
```
The console shows what it does.
![03_shutdown_console_01](README_assets/03_shutdown_console_01.png)\
![03_shutdown_console_02](README_assets/03_shutdown_console_02.png)\
![03_shutdown_console_03](README_assets/03_shutdown_console_03.png)\
<BR/>
And just for laughs, here's the timings for this run.  All kept in a csv file in S3 at s3://health-engine-aws-poc/Experimental Results.csv
![Experimental Results](README_assets/Experimental Results.png)\
<BR />