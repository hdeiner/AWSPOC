### Starting out with AWS RDS Oracle

##### Concept

> [The] Oracle Corporation is an American multinational computer technology corporation headquartered in Redwood Shores, California. The company sells database software and technology, cloud engineered systems, and enterprise software products—particularly its own brands of database management systems. In 2019, Oracle was the second-largest software company by revenue and market capitalization. The company also develops and builds tools for database development and systems of middle-tier software, enterprise resource planning (ERP) software, Human Capital Management (HCM) software, customer relationship management (CRM) software, and supply chain management (SCM) software.
>
>Larry Ellison co-founded Oracle Corporation in 1977 with Bob Miner and Ed Oates under the name Software Development Laboratories (SDL). Ellison took inspiration from the 1970 paper written by Edgar F. Codd on relational database management systems (RDBMS) named "A Relational Model of Data for Large Shared Data Banks." He heard about the IBM System R database from an article in the IBM Research Journal provided by Oates. Ellison wanted to make Oracle's product compatible with System R, but failed to do so as IBM kept the error codes for their DBMS a secret. SDL changed its name to Relational Software, Inc (RSI) in 1979, then again to Oracle Systems Corporation in 1983, to align itself more closely with its flagship product Oracle Database. At this stage Bob Miner served as the company's senior programmer. On March 12, 1986, the company had its initial public offering.
> 
> In 1995, Oracle Systems Corporation changed its name to Oracle Corporation, officially named Oracle, but sometimes referred to as Oracle Corporation, the name of the holding company. Part of Oracle Corporation's early success arose from using the C programming language to implement its products. This eased porting to different operating systems most of which support C.
>
> https://en.wikipedia.org/wiki/Oracle_Corporation
>
>
> It's been a long time since 1977.  Today, Oracle revenue has risen to about $10B annually, with revenue of over $2B annually.  Larry Ellison has a personal net worth of almost $76B, according to Forbes.  Unhappily, the companay has not made many changes which keep up with the times, and has seduced it's users with wonderful features to stay relevant in a manner that is both closed and with a huge barrier to switch.  We are reaching the point where our company's future becomes an extension of Larry's largesse.  Should Larry decide that he would like to fund his hobby in souped up America's Cup high tech catamarans by trippling license fees, we would have no choice except to pay it.
>
> So, why is this experiment in here, you ask?  It should be a slam dunk to get HealthEngine working in the cloud with this.  It provides a baseline for performance against other implementations, and a baseline on the economics of moving away from Oracle at this time.  Furthermore, as far as risk mitigation goes, this should be a very safe move to get into the cloud.
>
#### Execution

### 01_startup.sh
This script uses simple Terraform and applies it.   
```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Startup Oracle AWS"
terraform init
terraform apply -auto-approve
```
The terraform.aws_instance.tf is the most interesting of the terraform scripts because it does does all of the heavy lifting through provisiong.

The reason for doing the provisioning of the actual database, setting up the DDL using Liquibase, and loading sample data is that I don't want to install local clients (such as sqlplus) on the invoking machine.
```hcl-terraform
resource "aws_instance" "oracle_ec2_instance" {
  ami = "ami-00cf6ad74f988f94b"  #  Oracle Linux 7 update 7
#  instance_type = "m5.large"   # $0.096/hour ; 2 vCPU  ; 10 ECU  ; 8 GiB memory   ; EBS disk              ; EBS Optimized by default
  instance_type = "m5.xlarge"   # $0.192/hour ; 4 vCPU  ; 16 ECU  ; 16 GiB memory   ; EBS disk              ; EBS Optimized by default
#  instance_type = "m5d.metal" # $5.424/hour ; 96 vCPU ; 345 ECU ; 384 GiB memory ; 4 x 900 NVMe SSD disk ; EBS Optimized by default ; max bandwidth 19,000 Mbps ; max throughput 2,375 MB/s ; Max IOPS 80,000
  key_name = aws_key_pair.oracle_key_pair.key_name
  ebs_optimized = true
  security_groups = [aws_security_group.oracle.name]
  root_block_device {
    volume_type           = "io1"
    volume_size           = 30 # GB
    iops                  = 500
    delete_on_termination = true
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "provision.oracle.sh"
    destination = "/tmp/provision.oracle.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "mkdir -p /home/ec2-user/.aws",
    ]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/config"
    destination = "/home/ec2-user/.aws/config"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/credentials"
    destination = "/home/ec2-user/.aws/credentials"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "provision.oracle.response.file.rsp"
    destination = "/tmp/provision.oracle.response.file.rsp"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/provision.oracle.sh", "/tmp/provision.oracle.sh"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/java/Translator/changeSet.xml"
    destination = "/tmp/changeSet.xml"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../06_Cassandra_AWS/liquibase.jar"
    destination = "/tmp/liquibase.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../liquibase_drivers/ojdbc8.jar"
    destination = "/tmp/ojdbc8.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/import_GPG_keys.sh"
    destination = "/tmp/import_GPG_keys.sh"
  }
  provisioner "local-exec" {
    command = "../../data/export_GPG_keys.sh"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "HealthEngine.AWSPOC.public.key"
    destination = "/tmp/HealthEngine.AWSPOC.public.key"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "HealthEngine.AWSPOC.private.key"
    destination = "/tmp/HealthEngine.AWSPOC.private.key"
  }
  provisioner "local-exec" {
    command = "rm HealthEngine.AWSPOC.public.key HealthEngine.AWSPOC.private.key"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/transfer_from_s3_and_decrypt.sh"
    destination = "/tmp/transfer_from_s3_and_decrypt.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/import_GPG_keys.sh", "/tmp/import_GPG_keys.sh /tmp/HealthEngine.AWSPOC.public.key /tmp/HealthEngine.AWSPOC.private.key", "chmod +x /tmp/transfer_from_s3_and_decrypt.sh","rm /tmp/import_GPG_keys.sh /tmp/*.key"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "02_populate.sh"
    destination = "/tmp/02_populate.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/02_populate.sh", "/tmp/02_populate.sh"]
  }
  tags = {
    Name = "Oracle Instance"
  }
}
```
The script that is run on the EC2 instance (provision.oracle.sh) does the provisioning of the database itself.  It is written to run in Oracle Linux 7.7, which was called out in the ami used for the EC2 instance.
```bash
#!/usr/bin/env bash

sleep 15

echo "yum update"
sudo yum update -q -y
echo "yum install wget gcc make"
sudo yum install wget gcc make -q -y

echo "create figlet"
wget ftp://ftp.figlet.org/pub/figlet/program/unix/figlet-2.2.5.tar.gz --quiet
tar -xf figlet-2.2.5.tar.gz
cd figlet-2.2.5
sudo make install > figlet.log 2>&1
cd ..
rm -rf figlet-2.2.5 figlet-2.2.5.tar.gz

figlet -w 160 -f small "Install Oracle Prerequisites"
sudo yum install oracle-database-server-12cR2-preinstall zip unzip gnupg gnupg2 awscli java-1.8.0-openjdk -q -y

figlet -w 160 -f small "Create Oracle User"
sudo echo -e "FuckMeAgain\nFuckMeAgain" | sudo passwd oracle
sudo mkdir -p /u01/software
sudo chown -R oracle:oinstall /u01
sudo chmod -R 775 /u01

figlet -w 160 -f small "Fix Oracle 12 bash_profile"
echo '# Oracle specific environment and startup programs' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo 'export ORACLE_HOME=/u01/app/oracle/product/12.2.0.1.0/dbhome_1' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo 'export ORACLE_SID=ORCL' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo 'PATH=$PATH:$HOME/.local/bin:$ORACLE_HOME/bin' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo 'export PATH' | sudo tee -a /home/oracle/.bash_profile > /dev/null
sudo chown oracle /home/oracle

figlet -w 160 -f small "Setup Oracle for AWS CLI"
sudo mkdir /home/oracle/.aws
sudo cp -R /home/ec2-user/.aws/* /home/oracle/.aws/.

figlet -w 160 -f small "Setup Oracle for ssh"
sudo mkdir /home/oracle/.ssh
sudo cp /home/ec2-user/.ssh/authorized_keys /home/oracle/.ssh/.

figlet -w 160 -f small "Run Oracle 12 Setup"
# get the public dns in for the hostname
echo ORACLE_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname --silent` >> provision.oracle.response.file.rsp

sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cd /u01/software ; aws s3 cp --quiet s3://health-engine-aws-poc/linuxx64_12201_database.zip linuxx64_12201_database.zip ; unzip -qq linuxx64_12201_database.zip ; rm linuxx64_12201_database.zip ; cd /u01/software/database ; ./runInstaller -waitForCompletion -showProgress -silent -ignoreSysPrereqs -responseFile /tmp/provision.oracle.response.file.rsp'

figlet -w 160 -f small "Finish Oracle 12 Setup as root"

sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/12.2.0.1.0/dbhome_1/root.sh

figlet -w 160 -f small "DBCA Oracle Database"
#sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname cdb1 -sid cdb1 -responseFile NO_VALUE -characterSet AL32UTF8 -sysPassword OraPasswd1 -systemPassword OraPasswd1 -createAsContainerDatabase true -numberOfPDBs 1 -pdbName pdb1 -pdbAdminPassword OraPasswd1 -databaseType MULTIPURPOSE -automaticMemoryManagement false -storageType FS -ignorePreReqs'
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname ORCL -sid ORCL -responseFile NO_VALUE -characterSet AL32UTF8 -sysPassword OraPasswd1 -systemPassword OraPasswd1 -createAsContainerDatabase true -numberOfPDBs 1 -pdbName ORCLPDB -pdbAdminPassword OraPasswd1 -databaseType MULTIPURPOSE -automaticMemoryManagement false -createListener ORCL -storageType FS  -datafileDestination "/u01/app/oracle/oradata/" -redoLogFileSize 50  -emConfiguration NONE -ignorePreReqs'

figlet -w 160 -f small "Start Oracle Listener"
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; lsnrctl start'
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; lsnrctl services'
```
The script that is then run on the EC2 instance (02_populate.sh) runs Liquibase for the DDL and the Oracle command sqlldr for loading the data.
```bash
#!/usr/bin/env bash

sleep 2m
figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 200 -f small "Populate Oracle AWS"
# make schemaName="CE" in a line go away
sed --in-place --regexp-extended 's/schemaName\=\"CE\"//g' /tmp/changeSet.xml
# modify the tablenames in constraints clauses to include the CE in from of the tablemame.
sed --in-place --regexp-extended 's/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1CE.\2\3/g' /tmp/changeSet.xml
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cd /tmp ; java -jar liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@localhost:1521:ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc8.jar" --changeLogFile=changeSet.xml update'

figlet -w 160 -f small "Get Data from S3 Bucket"
/tmp/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv

figlet -w 160 -f small "Populate Oracle AWS"
touch /tmp/control.ctl ; chmod 666 /tmp/control.ctl
touch /tmp/control.log ; chmod 666 /tmp/control.log
touch /tmp/command.sql ; chmod 666 /tmp/command.sql

echo "Clinical_Condition"
# add header
sed -i '1 i\CLINICAL_CONDITION_COD|CLINICAL_CONDITION_NAM|INSERTED_BY|REC_INSERT_DATE|REC_UPD_DATE|UPDATED_BY|CLINICALCONDITIONCLASSCD|CLINICALCONDITIONTYPECD|CLINICALCONDITIONABBREV' ce.Clinical_Condition.csv
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
tr -d $'\r' <ce.Clinical_Condition.csv > /tmp/ce.Clinical_Condition.csv.mod
chmod 666 /tmp/ce.Clinical_Condition.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.Clinical_Condition.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.CLINICAL_CONDITION"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( CLINICAL_CONDITION_COD,' >> /tmp/control.ctl
echo '  CLINICAL_CONDITION_NAM,' >> /tmp/control.ctl
echo '  INSERTED_BY,' >> /tmp/control.ctl
echo '  REC_INSERT_DATE DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  REC_UPD_DATE DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDATED_BY,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONCLASSCD,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONTYPECD,' >> /tmp/control.ctl
echo '  CLINICALCONDITIONABBREV) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "DerivedFact"
# add header
sed -i '1 i\DERIVEDFACTID|DERIVEDFACTTRACKINGID|DERIVEDFACTTYPEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFact.csv
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
tr -d $'\r' <ce.DerivedFact.csv > /tmp/ce.DerivedFact.csv.mod
chmod 666 /tmp/ce.DerivedFact.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.DerivedFact.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.DERIVEDFACT"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( DERIVEDFACTID,' >> /tmp/control.ctl
echo '  DERIVEDFACTTRACKINGID,' >> /tmp/control.ctl
echo '  DERIVEDFACTTYPEID,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "DerivedFactProductUsage"
# add header
sed -i '1 i\DERIVEDFACTPRODUCTUSAGEID|DERIVEDFACTID|PRODUCTMNEMONICCD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFactProductUsage.csv
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
tr -d $'\r' <ce.DerivedFactProductUsage.csv > /tmp/ce.DerivedFactProductUsage.csv.mod
chmod 666 /tmp/ce.DerivedFactProductUsage.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.DerivedFactProductUsage.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.DERIVEDFACTPRODUCTUSAGE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( DERIVEDFACTPRODUCTUSAGEID,' >> /tmp/control.ctl
echo '  DERIVEDFACTID,' >> /tmp/control.ctl
echo '  PRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "MedicalFinding"
# add header
sed -i '1 i\MEDICALFINDINGID|MEDICALFINDINGTYPECD|MEDICALFINDINGNM|SEVERITYLEVELCD|IMPACTABLEFLG|CLINICAL_CONDITION_COD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|ACTIVEFLG|OPPORTUNITYPOINTSDISCRCD' ce.MedicalFinding.csv
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
tr -d $'\r' <ce.MedicalFinding.csv > /tmp/ce.MedicalFinding.csv.mod
chmod 666 /tmp/ce.MedicalFinding.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.MedicalFinding.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.MEDICALFINDING"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( MEDICALFINDINGID,' >> /tmp/control.ctl
echo '  MEDICALFINDINGTYPECD,' >> /tmp/control.ctl
echo '  MEDICALFINDINGNM,' >> /tmp/control.ctl
echo '  SEVERITYLEVELCD,' >> /tmp/control.ctl
echo '  IMPACTABLEFLG,' >> /tmp/control.ctl
echo '  CLINICAL_CONDITION_COD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  ACTIVEFLG,' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSDISCRCD) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "MedicalFindingType"
# add header
sed -i '1 i\MEDICALFINDINGTYPECD|MEDICALFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|HEALTHSTATEAPPLICABLEFLAG' ce.MedicalFindingType.csv
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
tr -d $'\r' <ce.MedicalFindingType.csv > /tmp/ce.MedicalFindingType.csv.mod
chmod 666 /tmp/ce.MedicalFindingType.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.MedicalFindingType.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.MEDICALFINDINGTYPE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( MEDICALFINDINGTYPECD,' >> /tmp/control.ctl
echo '  MEDICALFINDINGTYPEDESC,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  HEALTHSTATEAPPLICABLEFLAG) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "OpportunityPointsDiscr"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCRCD|OPPORTUNITYPOINTSDISCNM|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.OpportunityPointsDiscr.csv
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
tr -d $'\r' <ce.OpportunityPointsDiscr.csv > /tmp/ce.OpportunityPointsDiscr.csv.mod
chmod 666 /tmp/ce.OpportunityPointsDiscr.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.OpportunityPointsDiscr.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.OPPORTUNITYPOINTSDISCR"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( OPPORTUNITYPOINTSDISCRCD,' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSDISCNM,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "ProductFinding"
# add header
sed -i '1 i\PRODUCTFINDINGID|PRODUCTFINDINGNM|SEVERITYLEVELCD|PRODUCTFINDINGTYPECD|PRODUCTMNEMONICCD|SUBPRODUCTMNEMONICCD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|ACTIVEFLG|OPPORTUNITYPOINTSDISCRCD' ce.ProductFinding.csv
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
tr -d $'\r' <ce.ProductFinding.csv > /tmp/ce.ProductFinding.csv.mod
chmod 666 /tmp/ce.ProductFinding.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductFinding.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTFINDING"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( PRODUCTFINDINGID,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGNM,' >> /tmp/control.ctl
echo '  SEVERITYLEVELCD,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGTYPECD,' >> /tmp/control.ctl
echo '  PRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  SUBPRODUCTMNEMONICCD,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "ProductFindingType"
# add header
sed -i '1 i\PRODUCTFINDINGTYPECD|PRODUCTFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductFindingType.csv
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
tr -d $'\r' <ce.ProductFindingType.csv > /tmp/ce.ProductFindingType.csv.mod
chmod 666 /tmp/ce.ProductFindingType.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductFindingType.csv.mod" >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTFINDINGTYPE"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( PRODUCTFINDINGTYPECD,' >> /tmp/control.ctl
echo '  PRODUCTFINDINGTYPEDESC,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "ProductOpportunityPoints"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCCD|EFFECTIVESTARTDT|OPPORTUNITYPOINTSNBR|EFFECTIVEENDDT|DERIVEDFACTPRODUCTUSAGEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductOpportunityPoints.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductOpportunityPoints.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductOpportunityPoints.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductOpportunityPoints.csv
# get rid of timestamps without decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+[0-9]+//g' ce.ProductOpportunityPoints.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductOpportunityPoints.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductOpportunityPoints.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductOpportunityPoints.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductOpportunityPoints.csv
# get rid of ^M (return characters)
tr -d $'\r' <ce.ProductOpportunityPoints.csv > /tmp/ce.ProductOpportunityPoints.csv.mod
chmod 666 /tmp/ce.ProductOpportunityPoints.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.ProductOpportunityPoints.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.PRODUCTOPPORTUNITYPOINTS"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( OPPORTUNITYPOINTSDISCCD,' >> /tmp/control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  OPPORTUNITYPOINTSNBR,' >> /tmp/control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  DERIVEDFACTPRODUCTUSAGEID,' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  UPDTDBY) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

echo "Recommendation"
# get rid of ^M (return characters)
tr -d $'\r' <ce.Recommendation.csv > ce.Recommendation.csv.mod
# Merge every other line ince.Recommendation together with a comma between them
paste - - - -d'|' <ce.Recommendation.csv.mod > ce.Recommendation.csv
# add header
sed -i '1 i\RECOMMENDATIONSKEY|RECOMMENDATIONID|RECOMMENDATIONCODE|RECOMMENDATIONDESC|RECOMMENDATIONTYPE|CCTYPE|CLINICALREVIEWTYPE|AGERANGEID|ACTIONCODE|THERAPEUTICCLASS|MDCCODE|MCCCODE|PRIVACYCATEGORY|INTERVENTION|RECOMMENDATIONFAMILYID|RECOMMENDPRECEDENCEGROUPID|INBOUNDCOMMUNICATIONROUTE|SEVERITY|PRIMARYDIAGNOSIS|SECONDARYDIAGNOSIS|ADVERSEEVENT|ICMCONDITIONID|WELLNESSFLAG|VBFELIGIBLEFLAG|COMMUNICATIONRANKING|PRECEDENCERANKING|PATIENTDERIVEDFLAG|LABREQUIREDFLAG|UTILIZATIONTEXTAVAILABLEF|SENSITIVEMESSAGEFLAG|HIGHIMPACTFLAG|ICMLETTERFLAG|REQCLINICIANCLOSINGFLAG|OPSIMPELMENTATIONPHASE|SEASONALFLAG|SEASONALSTARTDT|SEASONALENDDT|EFFECTIVESTARTDT|EFFECTIVEENDDT|RECORDINSERTDT|RECORDUPDTDT|INSERTEDBY|UPDTDBY|STANDARDRUNFLAG|INTERVENTIONFEEDBACKFAMILYID|CONDITIONFEEDBACKFAMILYID|ASHWELLNESSELIGIBILITYFLAG|HEALTHADVOCACYELIGIBILITYFLAG' ce.Recommendation.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.Recommendation.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.Recommendation.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.Recommendation.csv
# get rid of timestamps without decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+[0-9]+//g' ce.Recommendation.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.Recommendation.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Recommendation.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Recommendation.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.Recommendation.csv
cp ce.Recommendation.csv /tmp/ce.Recommendation.csv.mod
chmod 666 /tmp/ce.Recommendation.csv.mod

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/ce.Recommendation.csv.mod"' >> /tmp/control.ctl
echo '  truncate into table "CE.RECOMMENDATION"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo '( RECOMMENDATIONSKEY,' >> /tmp/control.ctl
echo '  RECOMMENDATIONID,' >> /tmp/control.ctl
echo '  RECOMMENDATIONCODE,' >> /tmp/control.ctl
echo '  RECOMMENDATIONDESC,' >> /tmp/control.ctl
echo '  RECOMMENDATIONTYPE,' >> /tmp/control.ctl
echo '  CCTYPE,' >> /tmp/control.ctl
echo '  CLINICALREVIEWTYPE,' >> /tmp/control.ctl
echo '  AGERANGEID,' >> /tmp/control.ctl
echo '  ACTIONCODE,' >> /tmp/control.ctl
echo '  THERAPEUTICCLASS,' >> /tmp/control.ctl
echo '  MDCCODE,' >> /tmp/control.ctl
echo '  MCCCODE,' >> /tmp/control.ctl
echo '  PRIVACYCATEGORY,' >> /tmp/control.ctl
echo '  INTERVENTION,' >> /tmp/control.ctl
echo '  RECOMMENDATIONFAMILYID,' >> /tmp/control.ctl
echo '  RECOMMENDPRECEDENCEGROUPID,' >> /tmp/control.ctl
echo '  INBOUNDCOMMUNICATIONROUTE,' >> /tmp/control.ctl
echo '  SEVERITY,' >> /tmp/control.ctl
echo '  PRIMARYDIAGNOSIS,' >> /tmp/control.ctl
echo '  SECONDARYDIAGNOSIS,' >> /tmp/control.ctl
echo '  ADVERSEEVENT,' >> /tmp/control.ctl
echo '  ICMCONDITIONID,' >> /tmp/control.ctl
echo '  WELLNESSFLAG,' >> /tmp/control.ctl
echo '  VBFELIGIBLEFLAG,' >> /tmp/control.ctl
echo '  COMMUNICATIONRANKING,' >> /tmp/control.ctl
echo '  PRECEDENCERANKING,' >> /tmp/control.ctl
echo '  PATIENTDERIVEDFLAG,' >> /tmp/control.ctl
echo '  LABREQUIREDFLAG,' >> /tmp/control.ctl
echo '  UTILIZATIONTEXTAVAILABLEF,' >> /tmp/control.ctl
echo '  SENSITIVEMESSAGEFLAG,' >> /tmp/control.ctl
echo '  HIGHIMPACTFLAG,' >> /tmp/control.ctl
echo '  ICMLETTERFLAG,' >> /tmp/control.ctl
echo '  REQCLINICIANCLOSINGFLAG,' >> /tmp/control.ctl
echo '  OPSIMPELMENTATIONPHASE,' >> /tmp/control.ctl
echo '  SEASONALFLAG,' >> /tmp/control.ctl
echo '  SEASONALSTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  SEASONALENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  EFFECTIVESTARTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  EFFECTIVEENDDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDINSERTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  RECORDUPDTDT DATE "YYYY-MM-DD",' >> /tmp/control.ctl
echo '  INSERTEDBY,' >> /tmp/control.ctl
echo '  UPDTDBY,' >> /tmp/control.ctl
echo '  STANDARDRUNFLAG,' >> /tmp/control.ctl
echo '  INTERVENTIONFEEDBACKFAMILYID,' >> /tmp/control.ctl
echo '  CONDITIONFEEDBACKFAMILYID,' >> /tmp/control.ctl
echo '  ASHWELLNESSELIGIBILITYFLAG,' >> /tmp/control.ctl
echo '  HEALTHADVOCACYELIGIBILITYFLAG) ' >> /tmp/control.ctl
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log'

figlet -w 160 -f small "Check Oracle AWS"
echo 'SET LINESIZE 200;' >>/tmp/command.sql``
echo 'select * from "CE.CLINICAL_CONDITION" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.CLINICAL_CONDITION";' >>/tmp/command.sql``
echo 'select * from "CE.DERIVEDFACT" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.DERIVEDFACT";' >>/tmp/command.sql``
echo 'select * from "CE.DERIVEDFACTPRODUCTUSAGE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.DERIVEDFACTPRODUCTUSAGE";' >>/tmp/command.sql``
echo 'select * from "CE.MEDICALFINDING" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.MEDICALFINDING";' >>/tmp/command.sql``
echo 'select * from "CE.MEDICALFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.MEDICALFINDINGTYPE";' >>/tmp/command.sql``
echo 'select * from "CE.OPPORTUNITYPOINTSDISCR" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.OPPORTUNITYPOINTSDISCR";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTFINDING" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTFINDING";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTFINDINGTYPE" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTFINDINGTYPE";' >>/tmp/command.sql``
echo 'select * from "CE.PRODUCTOPPORTUNITYPOINTS" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.PRODUCTOPPORTUNITYPOINTS";' >>/tmp/command.sql``
echo 'select * from "CE.RECOMMENDATION" FETCH FIRST 2 ROWS ONLY;' >>/tmp/command.sql``
echo 'select count(*) from "CE.RECOMMENDATION";' >>/tmp/command.sql``
sudo -u oracle bash -c 'source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL'

rm /tmp/control.ctl /tmp/control.log /tmp/command.sql /tmp/changeSet.xml /tmp/*.mod *.csv *.mod
```
This is what the console looks like when the script is executed.  It takes about 12 minutes.  But it is completely repeatable, and doesn't require any manual intervention.  It's the way our DBAs should create Oracle instances, regardless of the environment.  Everything is in Git, and anyone can use it.
![01_startup_console_01](README_assets/01_startup_console_01.png)\
![01_startup_console_02](README_assets/01_startup_console_02.png)\
![01_startup_console_03](README_assets/01_startup_console_03.png)\
![01_startup_console_04](README_assets/01_startup_console_04.png)\
![01_startup_console_05](README_assets/01_startup_console_05.png)\
![01_startup_console_06](README_assets/01_startup_console_06.png)\
![01_startup_console_07](README_assets/01_startup_console_07.png)\
![01_startup_console_08](README_assets/01_startup_console_08.png)\
![01_startup_console_09](README_assets/01_startup_console_09.png)\
![01_startup_console_10](README_assets/01_startup_console_10.png)\
![01_startup_console_11](README_assets/01_startup_console_11.png)\
![01_startup_console_12](README_assets/01_startup_console_12.png)\
![01_startup_console_13](README_assets/01_startup_console_13.png)\
![01_startup_console_14](README_assets/01_startup_console_14.png)\
![01_startup_console_15](README_assets/01_startup_console_15.png)\
![01_startup_console_16](README_assets/01_startup_console_16.png)\
![01_startup_console_17](README_assets/01_startup_console_17.png)\
![01_startup_console_18](README_assets/01_startup_console_18.png)\
![01_startup_console_19](README_assets/01_startup_console_19.png)\
![01_startup_console_20](README_assets/01_startup_console_20.png)\
![01_startup_console_21](README_assets/01_startup_console_21.png)\
![01_startup_console_22](README_assets/01_startup_console_22.png)\
![01_startup_console_23](README_assets/01_startup_console_23.png)\
![01_startup_console_24](README_assets/01_startup_console_24.png)\
![01_startup_console_25](README_assets/01_startup_console_25.png)\
![01_startup_console_26](README_assets/01_startup_console_26.png)\
![01_startup_console_27](README_assets/01_startup_console_27.png)\
![01_startup_console_28](README_assets/01_startup_console_28.png)\
![01_startup_console_29](README_assets/01_startup_console_29.png)\
![01_startup_console_30](README_assets/01_startup_console_30.png)\
![01_startup_console_31](README_assets/01_startup_console_31.png)\
![01_startup_console_32](README_assets/01_startup_console_32.png)\
![01_startup_console_33](README_assets/01_startup_console_33.png)\
![01_startup_console_34](README_assets/01_startup_console_34.png)\
![01_startup_console_35](README_assets/01_startup_console_35.png)\
![01_startup_console_36](README_assets/01_startup_console_36.png)\
![01_startup_console_37](README_assets/01_startup_console_37.png)\
![01_startup_console_38](README_assets/01_startup_console_38.png)\
![01_startup_console_39](README_assets/01_startup_console_39.png)\
![01_startup_console_40](README_assets/01_startup_console_40.png)\
![01_startup_console_41](README_assets/01_startup_console_41.png)\
![01_startup_console_42](README_assets/01_startup_console_42.png)\
![01_startup_console_43](README_assets/01_startup_console_43.png)\
![01_startup_console_44](README_assets/01_startup_console_44.png)\
![01_startup_console_45](README_assets/01_startup_console_45.png)\
![01_startup_console_46](README_assets/01_startup_console_46.png)\
![01_startup_console_47](README_assets/01_startup_console_47.png)\
![01_startup_console_48](README_assets/01_startup_console_48.png)\
![01_startup_console_49](README_assets/01_startup_console_49.png)\
![01_startup_console_50](README_assets/01_startup_console_50.png)\
![01_startup_console_51](README_assets/01_startup_console_51.png)\
![01_startup_console_52](README_assets/01_startup_console_52.png)\
![01_startup_console_53](README_assets/01_startup_console_53.png)\
![01_startup_console_54](README_assets/01_startup_console_54.png)\
![01_startup_console_55](README_assets/01_startup_console_55.png)\
![01_startup_console_56](README_assets/01_startup_console_56.png)\
![01_startup_console_57](README_assets/01_startup_console_57.png)\
![01_startup_console_58](README_assets/01_startup_console_58.png)\
![01_startup_console_59](README_assets/01_startup_console_59.png)\
![01_startup_console_60](README_assets/01_startup_console_60.png)\
<BR/>
If we were to peruse the AWS Console EC2 Dashboard, here's what we will see.
![01_startup_aws_console_ec2_dashboard_01](README_assets/01_startup_aws_console_ec2_dashboard_01.png)\
<BR/>
Looking at the running instances, we see
![01_startup_aws_console_ec2_dashboard_02](README_assets/01_startup_aws_console_ec2_dashboard_02.png)\
<BR/>
Looking at details of that runing instance, we see
![01_startup_aws_console_ec2_dashboard_03](README_assets/01_startup_aws_console_ec2_dashboard_03.png)\
<BR/>
The security tab of that runing instance shows us
![01_startup_aws_console_ec2_dashboard_04](README_assets/01_startup_aws_console_ec2_dashboard_04.png)\
<BR/>
The networking tab of that runing instance shows us
![01_startup_aws_console_ec2_dashboard_05](README_assets/01_startup_aws_console_ec2_dashboard_05.png)\
<BR/>
The storage tab of that runing instance shows us
![01_startup_aws_console_ec2_dashboard_06](README_assets/01_startup_aws_console_ec2_dashboard_06.png)\
<BR/>
And, finally, the monitoring tab of that runing instance shows us
![01_startup_aws_console_ec2_dashboard_07](README_assets/01_startup_aws_console_ec2_dashboard_07.png)\
<BR/>
### 02_populate.sh
This script was run on the AWS EC2 instance in the 01_startup.sh for this experiment to avoid having to install Oracle clients on our local machine.
<BR/>
### 03_shutdown.sh
This script is extremely simple.  It tells terraform to destroy all that it created.

```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown Oracle AWS"
terraform destroy -auto-approve
```
The console shows what it does.
![03_shutdown_console_01](README_assets/03_shutdown_console_01.png)\
<BR/>
