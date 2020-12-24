### Starting out with AWS Apache Ignite

##### Concept

> Apache Ignite is an open-source distributed database (without rolling upgrade), caching and processing platform designed to store and compute on large volumes of data across a cluster of nodes.
>
> Ignite was open-sourced by GridGain Systems in late 2014 and accepted in the Apache Incubator program that same year. The Ignite project graduated on September 18, 2015.
>
> Apache Ignite's database utilizes RAM as the default storage and processing tier, thus, belonging to the class of in-memory computing platforms. The disk tier is optional but, once enabled, will hold the full data set whereas the memory tier will cache full or partial data set depending on its capacity.
>
> Regardless of the API used, data in Ignite is stored in the form of key-value pairs. The database component scales horizontally, distributing key-value pairs across the cluster in such a way that every node owns a portion of the overall data set. Data is rebalanced automatically whenever a node is added to or removed from the cluster.
>
> On top of its distributed foundation, Apache Ignite supports a variety of APIs including JCache-compliant key-value APIs, ANSI-99 SQL with joins, ACID transactions, as well as MapReduce like computations.
>
> Apache Ignite cluster can be deployed on-premise on a commodity hardware, in the cloud (e.g. Microsoft Azure, AWS, Google Compute Engine) or in a containerized and provisioning environments such as Kubernetes, Docker, Apache Mesos, VMWare. 
>
> https://en.wikipedia.org/wiki/Apache_Ignite
>
> https://www.gridgain.com

#### Execution

### 01_startup.sh
This script uses simple Terraform and applies it.   
```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Startup Ignite AWS Cluster"
terraform init
terraform apply -auto-approve
```
The terraform.aws_instance.tf is the most interesting of the terraform scripts because it does does all of the heavy lifting through provisiong.

The reason for doing the provisioning of the actual database and loading sample data is that I don't want to install local clients on the invoking machine.
```hcl-terraform
resource "aws_instance" "ignite_ec2_instance" {
  ami = "ami-0ac80df6eff0e70b5"  #  Ubuntu 18.04 LTS - Bionic - hvm:ebs-ssde  https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "m5.large"   # $0.096/hour ; 2 vCPU  ; 10 ECU  ; 8 GiB memory   ; EBS disk              ; EBS Optimized by default
#  instance_type = "m5d.metal" # $5.424/hour ; 96 vCPU ; 345 ECU ; 384 GiB memory ; 4 x 900 NVMe SSD disk ; EBS Optimized by default ; max bandwidth 19,000 Mbps ; max throughput 2,375 MB/s ; Max IOPS 80,000
  key_name = aws_key_pair.ignite_key_pair.key_name
  ebs_optimized = true
  security_groups = [aws_security_group.ignite.name]
  root_block_device {
    volume_type           = "io1"
    volume_size           = 30 # GB
    iops                  = 500
    delete_on_termination = true
  }
  count = 2
  tags = {
    Name = "Ignite Instance ${format("%03d", count.index)}"
  }
  #  provisioner "local-exec" {
  #    command = "aws ec2 wait instance-status-ok --region ${regex("[a-z]+[^a-z][a-z]+[^a-z][0-9]+",self.availability_zone)} --instance-ids ${aws_instance.ignite_ec2_instance[count.index].id}"
  #  }
  provisioner "local-exec" {
    command = "sleep 5m"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "mkdir -p /home/ubuntu/.aws",
    ]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/config"
    destination = "/home/ubuntu/.aws/config"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/credentials"
    destination = "/home/ubuntu/.aws/credentials"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "provision.ignite.cluster-config.xml"
    destination = "provision.ignite.cluster-config.xml"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "provision.ignite.fix-cluster-config.sh"
    destination = "provision.ignite.fix-cluster-config.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x provision.ignite.fix-cluster-config.sh"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "provision.ignite.sh"
    destination = "/tmp/provision.ignite.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/provision.ignite.sh", "/tmp/provision.ignite.sh"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/changeset.ignite.sql"
    destination = "/tmp/ddl.sql"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
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
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "HealthEngine.AWSPOC.public.key"
    destination = "/tmp/HealthEngine.AWSPOC.public.key"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
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
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/transfer_from_s3_and_decrypt.sh"
    destination = "/tmp/transfer_from_s3_and_decrypt.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/import_GPG_keys.sh", "/tmp/import_GPG_keys.sh /tmp/HealthEngine.AWSPOC.public.key /tmp/HealthEngine.AWSPOC.private.key", "chmod +x /tmp/transfer_from_s3_and_decrypt.sh","rm /tmp/import_GPG_keys.sh /tmp/*.key"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "02_populate.sh"
    destination = "/tmp/02_populate.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/02_populate.sh", "/tmp/02_populate.sh"]
  }
}
```
The script that is run on the EC2 instance (provision.ignite.sh) does the provisioning of the database itself.  There is some rather nasty stuff to do, such as build a config for Ignite that collects the private IP addresses for the EC2 instances that comprise the cluster and use them in the config file.  Also, installing Apache Ignite as a systemd service.
```bash
#!/usr/bin/env bash

sudo apt update -y -qq > provision.log
sudo apt-get update -y -qq >> provision.log
sudo apt-get install -y -qq figlet >> provision.log

figlet -w 160 -f small "Install Prerequisites"
sudo apt install -y -qq openjdk-8-jdk wget unzip awscli gnupg gnupg2 >> provision.log

figlet -w 160 -f small "Fetch Apache Ignite 2.9.0"
wget -q http://mirror.linux-ia64.org/apache/ignite/2.9.0/apache-ignite-2.9.0-bin.zip
unzip apache-ignite-2.9.0-bin.zip >> provision.log
rm apache-ignite-2.9.0-bin.zip

figlet -w 160 -f small "Fix Apache Ignite Cluster Configuration"
./provision.ignite.fix-cluster-config.sh > provision.ignite.cluster-config-fixed.xml
echo '</beans>' >> provision.ignite.cluster-config-fixed.xml # small error in script

figlet -w 160 -f small "Make Ignite a systemd Service"
bash -c 'cat << "EOF" > /home/ubuntu/startIgnite.sh
#!/bin/bash
IGNITE_HOME=/home/ubuntu/apache-ignite-2.9.0-bin
export IGNITE_HOME
/home/ubuntu/apache-ignite-2.9.0-bin/bin/ignite.sh /home/ubuntu/provision.ignite.cluster-config-fixed.xml
EOF'

chmod 755 /home/ubuntu/startIgnite.sh

sudo bash -c 'cat << "EOF" > /lib/systemd/system/ignite.service
[Unit]
Description=Apache Ignite Service
After=network.target

[Service]
WorkingDirectory=/home/ubuntu
User=ubuntu
PrivateDevices=yes
ProtectSystem=full
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=10
ExecStart=/home/ubuntu/startIgnite.sh
SyslogIdentifier=Ignite
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
Alias=ignite.service
EOF'

sudo systemctl daemon-reload
sudo systemctl enable ignite.service

figlet -w 160 -f small "Start Apache Ignite"
sudo service ignite start

figlet -w 160 -f small "Wait For Ignite To Start"

while true ; do
  result=$(ls -Art apache-ignite-2.9.0-bin/work/log/*.log | wc -l)
  if [ $result != 0 ] ; then
    break
  fi
  sleep 5
done

ls -Art apache-ignite-2.9.0-bin/work/log/*.log | tail -n 1 > .logfile

while true ; do
  result=$(grep -cE "Ignite ver\. 2\.9\.0" < $(cat .logfile))
  if [ $result != 0 ] ; then
    echo "Ignite has started"
    break
  fi
  sleep 5
done
```
The script that is run on the EC2 instance (02_populate.sh) is also worthy of note, as it runs on each instance in the Ignite cluster.  While it's not hard to allow the load to be shared among all the cluster members to populate the cluster, you will find code that has each cluster member except the first to inhibit doing any Ignite loading, so that performance measuring can be more easily assessed.  You will also find significant work done using sed, tr, and paste to transform the | seperated fields into true csv files.
```bash
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > .instanceName
result=$(grep -cE 'Ignite Instance 000' .instanceName)
if [ $result == 1 ]
then
  figlet -w 160 -f small "Populate Ignite Schema AWS Cluster"

  echo "Apply Schema"
  ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql

  echo "Import ce.Clinical_Condition.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
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
  tr -d $'\r' < ce.Clinical_Condition.csv > ce.Clinical_Condition.csv.mod
  echo 'COPY FROM '\'ce.Clinical_Condition.csv.mod\'' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM,INSERTED_BY,REC_INSERT_DATE,REC_UPD_DATE,UPDATED_BY,CLINICALCONDITIONCLASSCD,CLINICALCONDITIONTYPECD,CLINICALCONDITIONABBREV) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.DerivedFact.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
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
  tr -d $'\r' < ce.DerivedFact.csv > ce.DerivedFact.csv.mod
  echo 'COPY FROM '\'ce.DerivedFact.csv.mod\'' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.DerivedFactProductUsage.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
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
  tr -d $'\r' < ce.DerivedFactProductUsage.csv > ce.DerivedFactProductUsage.csv.mod
  echo 'COPY FROM '\'ce.DerivedFactProductUsage.csv.mod\'' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.MedicalFinding.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
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
  tr -d $'\r' < ce.MedicalFinding.csv > ce.MedicalFinding.csv.mod
  echo 'COPY FROM '\'ce.MedicalFinding.csv.mod\'' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD,MEDICALFINDINGNM,SEVERITYLEVELCD,IMPACTABLEFLG,CLINICAL_CONDITION_COD,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,ACTIVEFLG,OPPORTUNITYPOINTSDISCRCD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.MedicalFindingType.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
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
  tr -d $'\r' < ce.MedicalFindingType.csv > ce.MedicalFindingType.csv.mod
  echo 'COPY FROM '\'ce.MedicalFindingType.csv.mod\'' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY,HEALTHSTATEAPPLICABLEFLAG) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.ProductOpportunityPoints.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
  # convert comas to semi-colons
  sed --in-place --regexp-extended 's/,/;/g' ce.ProductOpportunityPoints.csv
  # convert bars to commas
  sed --in-place 's/|/,/g' ce.ProductOpportunityPoints.csv
  # get rid of timestamps and decimals after timestamp
  sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductOpportunityPoints.csv
  # remove blanks at start of line
  sed --in-place --regexp-extended 's/^ *//g' ce.ProductOpportunityPoints.csv
  # remove blanks before commas
  sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductOpportunityPoints.csv
  # remove blanks after commas
  sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductOpportunityPoints.csv
  # remove blanks at end of line
  sed --in-place --regexp-extended 's/ *$//g' ce.ProductOpportunityPoints.csv
  # get rid of ^M (return characters)
  tr -d $'\r' < ce.ProductOpportunityPoints.csv > ce.ProductOpportunityPoints.csv.mod
  echo 'COPY FROM '\'ce.ProductOpportunityPoints.csv.mod\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD,EFFECTIVESTARTDT,OPPORTUNITYPOINTSNBR,EFFECTIVEENDDT,DERIVEDFACTPRODUCTUSAGEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  echo "Import ce.Recommendation.csv"
  /tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
# get rid of ^M (return characters)
  tr -d $'\r' < ce.Recommendation.csv > ce.Recommendation.csv.mod
  # Merge every other line in ce.Recommendation together with a comma between them
  paste - - - -d'|' < ce.Recommendation.csv.mod > ce.Recommendation.csv
  # convert comas to semi-colons
  sed --in-place --regexp-extended 's/,/;/g' ce.Recommendation.csv
  # convert bars to commas
  sed --in-place 's/|/,/g' ce.Recommendation.csv
  # get rid of timestamps and decimals after timestamp
  sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.Recommendation.csv
  # remove blanks at start of line
  sed --in-place --regexp-extended 's/^ *//g' ce.Recommendation.csv
  # remove blanks before commas
  sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Recommendation.csv
  # remove blanks after commas
  sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Recommendation.csv
  # remove blanks at end of line
  sed --in-place --regexp-extended 's/ *$//g' ce.Recommendation.csv
  echo 'COPY FROM '\'ce.Recommendation.csv\'' INTO SQL_CE_RECOMMENDATION(RECOMMENDATIONSKEY,RECOMMENDATIONID,RECOMMENDATIONCODE,RECOMMENDATIONDESC,RECOMMENDATIONTYPE,CCTYPE,CLINICALREVIEWTYPE,AGERANGEID,ACTIONCODE,THERAPEUTICCLASS,MDCCODE,MCCCODE,PRIVACYCATEGORY,INTERVENTION,RECOMMENDATIONFAMILYID,RECOMMENDPRECE_ENCE_ROUPID,INBOUNDCOMMUNICATIONROUTE,SEVERITY,PRIMARYDIAGNOSIS,SECONDARYDIAGNOSIS,ADVERSEEVENT,ICMCONDITIONID,WELLNESSFLAG,VBFELIGIBLEFLAG,COMMUNICATIONRANKING,PRECE_ENCE_ANKING,PATIENTDERIVEDFLAG,LABREQUIREDFLAG,UTILIZATIONTEXTAVAILABLEF,SENSITIVEMESSAGEFLAG,HIGHIMPACTFLAG,ICMLETTERFLAG,REQCLINICIANCLOSINGFLAG,OPSIMPELMENTATIONPHASE,SEASONALFLAG,SEASONALSTARTDT,SEASONALENDDT,EFFECTIVESTARTDT,EFFECTIVEENDDT,RECORDINSERTDT,RECORDUPDTDT,INSERTEDBY,UPDTDBY,STANDARDRUNFLAG,INTERVENTIONFEEDBACKFAMILYID,CONDITIONFEEDBACKFAMILYID,ASHWELLNESSELIGIBILITYFLAG,HEALTHADVOCACYELIGIBILITYFLAG) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1

  figlet -w 160 -f small "Check Ignite AWS Cluster"
  echo 'SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  echo 'SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
  rm *.csv *.mod
else
  figlet -w 160 -f small "only run on 000 instance"
fi
```
This is what the console looks like when the script is executed.  It takes about 12 minutes, is completely repeatable, and doesn't require any manual intervention.  
![01_startup_console_01](README_assets/01_startup_console_01.png)\
![01_startup_console_02](README_assets/01_startup_console_02.png)\
![01_startup_console_03](README_assets/01_startup_console_03.png)\
![01_startup_console_04](README_assets/01_startup_console_04.png)\
![01_startup_console_05](README_assets/01_startup_console_05.png)\
![01_startup_console_06](README_assets/01_startup_console_05.png)\
![01_startup_console_07](README_assets/01_startup_console_06.png)\
![01_startup_console_08](README_assets/01_startup_console_07.png)\
![01_startup_console_09](README_assets/01_startup_console_08.png)\
![01_startup_console_10](README_assets/01_startup_console_09.png)\
![01_startup_console_11](README_assets/01_startup_console_10.png)\
![01_startup_console_12](README_assets/01_startup_console_11.png)\
![01_startup_console_13](README_assets/01_startup_console_12.png)\
![01_startup_console_14](README_assets/01_startup_console_13.png)\
![01_startup_console_15](README_assets/01_startup_console_14.png)\
![01_startup_console_16](README_assets/01_startup_console_15.png)\
![01_startup_console_17](README_assets/01_startup_console_16.png)\
![01_startup_console_18](README_assets/01_startup_console_17.png)\
![01_startup_console_19](README_assets/01_startup_console_18.png)\
![01_startup_console_20](README_assets/01_startup_console_19.png)\
![01_startup_console_21](README_assets/01_startup_console_20.png)\
<BR/>
If we were to peruse the AWS Console EC2 Dashboard, here's what we will see.
![01_startup_aws_console_ec2_dashboard_01](README_assets/01_startup_aws_console_ec2_dashboard_01.png)\
<BR/>
Looking at the first running instance, we see
![01_startup_aws_console_ec2_dashboard_02](README_assets/01_startup_aws_console_ec2_dashboard_02.png)\
<BR/>
Looking at details tab of that runing instance, we see
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
This script was run on the AWS EC2 instance in the 01_startup.sh for this experiment to avoid having to install Apache Ignite clients on our local machine.
<BR/>
### 03_shutdown.sh
This script is extremely simple.  It tells terraform to destroy all that it created.

```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown Ignite AWS Cluster"
terraform destroy -auto-approve
```
The console shows what it does.
![04_shutdown_console_01](README_assets/04_shutdown_console_01.png)\
<BR/>
And just for laughs, here's the timings for this run.  All kept in a csv file in S3 at s3://health-engine-aws-poc/Experimental Results.csv
![Experimental Results](README_assets/Experimental Results.png)\
<BR />

### Large Data Experiments

A different script is available for large data testing.  This transfers the dataset for large volume testing.  It uses the data from the "Complete 2019 Program Year Open Payments Dataset" from the Center for Medicare & Medicade Services.  See https://www.cms.gov/OpenPayments/Explore-the-Data/Dataset-Downloads for details.  In total, there is over 6GB in this dataset.

The script 02_populate_large_data.sh is a variation on 02_populate.sh.
```bash
#!/usr/bin/env bash

ROWS=$(</tmp/.rows)
export ROWS

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName
result=$(grep -cE 'Ignite_Instance_000' .instanceName)
if [ $result == 1 ]
then
  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"
figlet -w 240 -f small "Populate Ignite AWS - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small "Apply Schema for Ignite - Large Data - $(numfmt --grouping $ROWS) rows"
cp /tmp/PGYR19_P063020.changeset.cassandra.sql .changeset.sql
sed --in-place --regexp-extended '"'"'s/PGYR19_P063020\.PI/PGYR2019_P06302020/g'"'"' .changeset.sql
sed --in-place --regexp-extended '"'"'s/TIMESTAMP/DATE/g'"'"' .changeset.sql
sed --in-place --regexp-extended '"'"'s/TEXT/INT/g'"'"' .changeset.sql
sed --in-place --regexp-extended '"'"'s/record_id INT PRIMARY KEY/record_id BIGINT PRIMARY KEY/g'"'"' .changeset.sql
./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f .changeset.sql
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS: Populate Ignite Schema "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv

  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
/tmp/transferPGYR19_P063020_from_s3_and_decrypt.sh > /dev/null
python3 /tmp/create_csv_data_PGYR2019_P06302020.py -s $ROWS -i /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv -o /tmp/PGYR2019_P06302020.csv
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS: Get Data from S3 Bucket "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm .script .results Experimental\ Results.csv

  command time -v /tmp/02_populate_large_data_load_data.sh $ROWS 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS: Populate Ignite Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm -rf .script .results Experimental\ Results.csv /tmp/PGYR2019_P06302020.csv

  bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Ignite Data - Large Data - $(numfmt --grouping $ROWS) rows"

echo ""
echo "First two rows of data"
echo "SELECT * FROM PGYR2019_P06302020 FETCH FIRST 2 ROWS ONLY;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo ""
echo "Count of rows of data"
echo "SELECT COUNT(*) FROM PGYR2019_P06302020;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo ""
echo "Average of total_amount_of_payment_usdollars"
echo "SELECT AVG(total_amount_of_payment_usdollars) FROM PGYR2019_P06302020;" | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo ""
echo "Top ten earning physicians"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars) " > .command.sql
echo "FROM PGYR2019_P06302020 " >> .command.sql
echo "WHERE physician_first_name != '"'"''"'"' " >> .command.sql
echo "AND physician_last_name != '"'"''"'"' " >> .command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> .command.sql
echo "ORDER BY SUM(total_amount_of_payment_usdollars) DESC " >> .command.sql
echo "FETCH FIRST 10 ROWS ONLY; " >> .command.sql
./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1 -f .command.sql
EOF'
  chmod +x .script
  command time -v ./.script 2> .results
  /tmp/getExperimentalResults.sh
  experiment=$(/tmp/getExperimentNumber.sh)
  /tmp/getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS: Check Ignite Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
  /tmp/putExperimentalResults.sh
  rm -rf .script .sql .results .command.sql *.csv /tmp/PGYR19_P063020
else
  figlet -w 160 -f small "only run on 000 instance"
fi
```

As you can see, there are two helper scripts to actually do the data load.  The first is a Python program called create_csv_data_PGYR2019_P06302020.py, which takes the raw "Complete 2019 Program Year Open Payments Dataset" and creates a csv file that Ignite can actually use to load the data.  Apache Ignite has a CSV Bulk Loader, but it does not work with quoted data CSV files yet.  As such, we will incur a penalty in the data load timings, as we have to run this run the helper program, before we can actually load the data.  The code look like this:

```python
import argparse
import os
import csv
import re
from subprocess import call

def get_args():
    """get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='cleansePGYR10_P063030 Data',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-s',
                        '--size',
                        help='Size in rows of file to take',
                        metavar='int',
                        type=str,
                        default=1000)

    parser.add_argument('-i',
                        '--inputfile',
                        help='Input filename',
                        metavar='str',
                        type=str,
                        default='')

    parser.add_argument('-o',
                        '--outputfile',
                        help='Output filename',
                        metavar='str',
                        type=str,
                        default='')

    args = parser.parse_args()

    return args

def create_insert_data(filesize, filenamein, filenameout):
    call("rm -rf "+filenameout, shell=True)

    csv_file_out = open(filenameout, mode='w')

    with open(filenamein) as csv_file_in:
        csv_reader = csv.reader(csv_file_in, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if (line_count != 0):
                while ("'" in row[6]):   # Physician_First_Name
                    row[6] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[6])

                while (',' in row[6]):   # Physician_First_Name
                    row[6] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[6])

                while ("'" in row[7]):   # Physician_Middle_Name
                    row[7] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[7])

                while (',' in row[7]):   # Physician_Middle_Name
                    row[7] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[7])

                while ("'" in row[8]):   # Physician_Last_Name
                    row[8] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[8])

                while (',' in row[8]):  # Physician_Last_Name
                    row[8] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[8])

                while ("'" in row[9]):   # Physician_Name_Suffix
                    row[9] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[9])

                while (',' in row[9]):  # Physician_Name_Suffix
                    row[9] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[9])

                while ("'" in row[10]):   # Recipient_Primary_Business_Street_Address_Line1
                    row[10] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[10])

                while ('"' in row[10]):  # Recipient_Primary_Business_Street_Address_Line1
                    row[10] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[10])

                while (',' in row[10]):  # Recipient_Primary_Business_Street_Address_Line1
                    row[10] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[10])

                while ("'" in row[11]):   # Recipient_Primary_Business_Street_Address_Line2
                    row[11] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[11])

                while (',' in row[11]):  # Recipient_Primary_Business_Street_Address_Line2
                    row[11] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[11])

                while ("'" in row[12]):   # Recipient_City
                    row[12] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[12])

                while (',' in row[12]):  # Recipient_City
                    row[12] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[12])

                while ("'" in row[19]):   # Physician_Specialty
                    row[19] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[19])

                while (',' in row[19]):  # Physician_Specialty
                    row[19] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[19])

                while ("'" in row[25]):   # Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name
                    row[25] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[25])

                while (',' in row[25]):  # Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name
                    row[25] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[25])

                while ("'" in row[27]):   # Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name
                    row[27] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[27])

                while (',' in row[27]):  # Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name
                    row[27] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[27])

                row[31] = re.sub(r'^(.*)(/)(.*)(/)(.*$)', r'\5-\1-\3', row[31]) #  Date_of_Payment

                while ("'" in row[33]):   # Form_of_Payment_or_Transfer_of_Value
                    row[33] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[33])

                while (',' in row[33]):  # Form_of_Payment_or_Transfer_of_Value
                    row[33] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[33])

                while ("'" in row[34]):   # Nature_of_Payment_or_Transfer_of_Value
                    row[34] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[34])

                while (',' in row[34]):  # Nature_of_Payment_or_Transfer_of_Value
                    row[34] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[34])

                while ("'" in row[35]):   # City_of_Travel
                    row[35] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[35])

                while (',' in row[35]):  # City_of_Travel
                    row[35] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[35])

                while ("'" in row[37]):   # Country_of_Travel
                    row[37] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[37])

                while (',' in row[37]):  # Country_of_Travel
                    row[37] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[37])

                while ("'" in row[40]):   # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                    row[40] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[40])

                while ('"' in row[40]):  # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                    row[40] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[40])

                while (',' in row[40]):  # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                    row[40] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[40])

                while ("'" in row[43]):   # Contextual_Information
                    row[43] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[43])

                while (',' in row[43]):  # Contextual_Information
                    row[43] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[43])

                while ("'" in row[49]):   # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_1
                    row[49] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[49])

                while (',' in row[49]):  # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_1
                    row[49] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[49])

                while ("'" in row[50]):   # Product_Category_or_Therapeutic_Area_1
                    row[50] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[50])

                while (',' in row[50]):  # Product_Category_or_Therapeutic_Area_1
                    row[50] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[50])

                while ("'" in row[51]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                    row[51] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[51])

                while (',' in row[51]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                    row[51] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[51])

                while ('"' in row[51]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                    row[51] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[51])

                while ("'" in row[52]):   # Associated_Drug_or_Biological_NDC_1
                    row[52] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[52])

                while (',' in row[52]):  # Associated_Drug_or_Biological_NDC_1
                    row[52] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[52])

                while ("'" in row[54]):   # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_2
                    row[54] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[54])

                while (',' in row[54]):  # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_2
                    row[54] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[54])

                while ("'" in row[55]):   # Product_Category_or_Therapeutic_Area_2
                    row[55] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[55])

                while (',' in row[55]):  # Product_Category_or_Therapeutic_Area_2
                    row[55] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[55])

                while ("'" in row[56]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                    row[56] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[56])

                while (',' in row[56]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                    row[56] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[56])

                while ('"' in row[56]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                    row[56] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[56])

                while ("'" in row[57]):   # Associated_Drug_or_Biological_NDC_2
                    row[57] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[57])

                while (',' in row[57]):  # Associated_Drug_or_Biological_NDC_2
                    row[57] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[57])

                while ("'" in row[60]):   # Product_Category_or_Therapeutic_Area_3
                    row[60] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[60])

                while (',' in row[60]):  # Product_Category_or_Therapeutic_Area_3
                    row[60] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[60])

                while ("'" in row[61]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                    row[61] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[61])

                while (',' in row[61]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                    row[61] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[61])

                while ('"' in row[61]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                    row[61] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[61])

                while ("'" in row[62]):   # Associated_Drug_or_Biological_NDC_3
                    row[62] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[62])

                while (',' in row[62]):  # Associated_Drug_or_Biological_NDC_3
                    row[62] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[62])

                while ("'" in row[65]):   # Product_Category_or_Therapeutic_Area_4
                    row[65] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[65])

                while (',' in row[65]):  # Product_Category_or_Therapeutic_Area_4
                    row[65] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[65])

                while ("'" in row[66]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                    row[66] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[66])

                while (',' in row[66]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                    row[66] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[66])

                while ('"' in row[66]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                    row[66] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[66])

                while ("'" in row[67]):   # Associated_Drug_or_Biological_NDC_4
                    row[67] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[67])

                while (',' in row[67]):  # Associated_Drug_or_Biological_NDC_4
                    row[67] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[67])

                while ("'" in row[70]):   # Product_Category_or_Therapeutic_Area_5
                    row[70] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[70])

                while (',' in row[70]):  # Product_Category_or_Therapeutic_Area_5
                    row[70] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[70])

                while ("'" in row[71]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                    row[71] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[71])

                while (',' in row[71]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                    row[71] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[71])

                while ('"' in row[71]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                    row[71] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[71])

                while ("'" in row[72]):   # Associated_Drug_or_Biological_NDC_5
                    row[72] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[72])

                while (',' in row[72]):  # Associated_Drug_or_Biological_NDC_5
                    row[72] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[72])

                row[74] = re.sub(r'^(.*)(/)(.*)(/)(.*$)', r'\5-\1-\3', row[74]) #  Payment_Publication_Date

                outrow = ""
                for i in range(75):
                    if (i in [3,5,30,32,45,73]):  #numbers
                        if (len(row[i]) == 0):
                            outrow += "0,"
                        else:
                            outrow += row[i] + ","
                    elif (i in [31,74]):    #dates
                        outrow += row[i] + ","
                    else:
                        outrow += row[i] + ","

                csv_file_out.write(outrow[:-1]+"\n")

            if (line_count < filesize):
                line_count += 1
            else:
                break

    csv_file_in.close()
    csv_file_out.close()

def main():
    args = get_args()

    if(args.inputfile == ''):
        print("You must specify an input filename")
        quit()
    if os.path.isfile(args.inputfile) != True:
        print("Input file does not exist")
        quit()
    if(args.outputfile == ''):
        print("You must specify an output filename")
        quit()

    create_insert_data(int(args.size),args.inputfile,args.outputfile)

    quit()

if __name__ == '__main__':
    main()
````

The other helper file is called 02_populate_large_data_load_data.sh.  For this experiment, it is REALLY simple, and looks like:

```bash
#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Ignite Data - Large Data - $ROWS rows"

sed -n 1,1p /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > .command
sed --in-place --regexp-extended 's/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g' .command
sed --in-place --regexp-extended 's/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Val/g' .command

sed --in-place '1s/^/COPY FROM '"'"'\/tmp\/PGYR2019_P06302020.csv'"'"' INTO PGYR2019_P06302020(/' .command
echo ") FORMAT CSV; " >> .command

./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f .command

rm .command
```
It uses the following schema, althout it does not use Liquibase to establish the database.
```xml
<?xml version="1.0" encoding="UTF-8"?>

<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
         http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">

    <changeSet  id="1"  author="howarddeiner">

        <createTable tableName="OP_DTL_GNRL_PGYR2019_P06302020" schemaName="PI">
            <column name="change_type" type="VARCHAR2(20)"/>
            <column name="covered_recipient_type" type="VARCHAR2(50)"/>
            <column name="teaching_hospital_ccn" type="VARCHAR2(06)"/>
            <column name="teaching_hospital_id" type="NUMBER(38,0)"/>
            <column name="teaching_hospital_name" type="VARCHAR2(100)"/>
            <column name="physician_profile_id" type="NUMBER(38,0)"/>
            <column name="physician_first_name" type="VARCHAR2(20)"/>
            <column name="physician_middle_name" type="VARCHAR2(20)"/>
            <column name="physician_last_name" type="VARCHAR2(35)"/>
            <column name="physician_name_suffix" type="VARCHAR2(5)"/>
            <column name="recipient_primary_business_street_address_line1" type="VARCHAR2(55)"/>
            <column name="recipient_primary_business_street_address_line2" type="VARCHAR2(55)"/>
            <column name="recipient_city" type="VARCHAR2(40)"/>
            <column name="recipient_state" type="CHAR(2)"/>
            <column name="recipient_zip_code" type="VARCHAR2(10)"/>
            <column name="recipient_country" type="VARCHAR2(100)"/>
            <column name="recipient_province" type="VARCHAR2(20)"/>
            <column name="recipient_postal_code" type="VARCHAR2(20)"/>
            <column name="physician_primary_type" type="VARCHAR2(100)"/>
            <column name="physician_specialty" type="VARCHAR2(300)"/>
            <column name="physician_license_state_code1" type="CHAR(2)"/>
            <column name="physician_license_state_code2" type="CHAR(2)"/>
            <column name="physician_license_state_code3" type="CHAR(2)"/>
            <column name="physician_license_state_code4" type="CHAR(2)"/>
            <column name="physician_license_state_code5" type="CHAR(2)"/>
            <column name="submitting_applicable_manufacturer_or_applicable_gpo_name" type="VARCHAR2(100)"/>
            <column name="applicable_manufacturer_or_applicable_gpo_making_payment_id" type="VARCHAR2(12)"/>
            <column name="applicable_manufacturer_or_applicable_gpo_making_payment_name" type="VARCHAR2(100)"/>
            <column name="applicable_manufacturer_or_applicable_gpo_making_payment_state" type="CHAR(2)"/>
            <column name="applicable_manufacturer_or_applicable_gpo_making_payment_countr" type="VARCHAR2(100)"/>
            <column name="total_amount_of_payment_usdollars" type="NUMBER(12,2)"/>
            <column name="date_of_payment" type="DATE"/>
            <column name="number_of_payments_included_in_total_amount" type="NUMBER(3,0)"/>
            <column name="form_of_payment_or_transfer_of_value" type="VARCHAR2(100)"/>
            <column name="nature_of_payment_or_transfer_of_value" type="VARCHAR2(200)"/>
            <column name="city_of_travel" type="VARCHAR2(40)"/>
            <column name="state_of_travel" type="CHAR(2)"/>
            <column name="country_of_travel" type="VARCHAR2(100)"/>
            <column name="physician_ownership_indicator" type="CHAR(3)"/>
            <column name="third_party_payment_recipient_indicator" type="VARCHAR2(50)"/>
            <column name="name_of_third_party_entity_receiving_payment_or_transfer_of_val" type="VARCHAR2(50)"/>
            <column name="charity_indicator" type="CHAR(3)"/>
            <column name="third_party_equals_covered_recipient_indicator" type="CHAR(3)"/>
            <column name="contextual_information" type="VARCHAR2(500)"/>
            <column name="delay_in_publication_indicator" type="CHAR(3)"/>
            <column name="record_id" type="NUMBER(38,0)"/>
            <column name="dispute_status_for_publication" type="CHAR(3)"/>
            <column name="related_product_indicator" type="VARCHAR2(100)"/>
            <column name="covered_or_noncovered_indicator_1" type="VARCHAR2(100)"/>
            <column name="indicate_drug_or_biological_or_device_or_medical_supply_1" type="VARCHAR2(100)"/>
            <column name="product_category_or_therapeutic_area_1" type="VARCHAR2(100)"/>
            <column name="name_of_drug_or_biological_or_device_or_medical_supply_1" type="VARCHAR2(500)"/>
            <column name="associated_drug_or_biological_ndc_1" type="VARCHAR2(100)"/>
            <column name="covered_or_noncovered_indicator_2" type="VARCHAR2(100)"/>
            <column name="indicate_drug_or_biological_or_device_or_medical_supply_2" type="VARCHAR2(100)"/>
            <column name="product_category_or_therapeutic_area_2" type="VARCHAR2(100)"/>
            <column name="name_of_drug_or_biological_or_device_or_medical_supply_2" type="VARCHAR2(500)"/>
            <column name="associated_drug_or_biological_ndc_2" type="VARCHAR2(100)"/>
            <column name="covered_or_noncovered_indicator_3" type="VARCHAR2(100)"/>
            <column name="indicate_drug_or_biological_or_device_or_medical_supply_3" type="VARCHAR2(100)"/>
            <column name="product_category_or_therapeutic_area_3" type="VARCHAR2(100)"/>
            <column name="name_of_drug_or_biological_or_device_or_medical_supply_3" type="VARCHAR2(500)"/>
            <column name="associated_drug_or_biological_ndc_3" type="VARCHAR2(100)"/>
            <column name="covered_or_noncovered_indicator_4" type="VARCHAR2(100)"/>
            <column name="indicate_drug_or_biological_or_device_or_medical_supply_4" type="VARCHAR2(100)"/>
            <column name="product_category_or_therapeutic_area_4" type="VARCHAR2(100)"/>
            <column name="name_of_drug_or_biological_or_device_or_medical_supply_4" type="VARCHAR2(500)"/>
            <column name="associated_drug_or_biological_ndc_4" type="VARCHAR2(100)"/>
            <column name="covered_or_noncovered_indicator_5" type="VARCHAR2(100)"/>
            <column name="indicate_drug_or_biological_or_device_or_medical_supply_5" type="VARCHAR2(100)"/>
            <column name="product_category_or_therapeutic_area_5" type="VARCHAR2(100)"/>
            <column name="name_of_drug_or_biological_or_device_or_medical_supply_5" type="VARCHAR2(500)"/>
            <column name="associated_drug_or_biological_ndc_5" type="VARCHAR2(100)"/>
            <column name="program_year" type="CHAR(4)"/>
            <column name="payment_publication_date" type="DATE"/>
        </createTable>

    </changeSet>

</databaseChangeLog>
```

<BR />
When run in conjunction with 01_startup_large_data.sh and 03_shutdown.sh for a sample size of 1,000,000 records, you will see:

![02_populate_large_data_1000000_01](README_assets/02_populate_large_data_1000000_01.png)\
![02_populate_large_data_1000000_02](README_assets/02_populate_large_data_1000000_02.png)\
![02_populate_large_data_1000000_03](README_assets/02_populate_large_data_1000000_03.png)\
![02_populate_large_data_1000000_04](README_assets/02_populate_large_data_1000000_04.png)\
![02_populate_large_data_1000000_05](README_assets/02_populate_large_data_1000000_05.png)\
![02_populate_large_data_1000000_06](README_assets/02_populate_large_data_1000000_06.png)\
![02_populate_large_data_1000000_07](README_assets/02_populate_large_data_1000000_07.png)\
![02_populate_large_data_1000000_08](README_assets/02_populate_large_data_1000000_08.png)\
![02_populate_large_data_1000000_09](README_assets/02_populate_large_data_1000000_09.png)\
![02_populate_large_data_1000000_10](README_assets/02_populate_large_data_1000000_10.png)\
<BR />
This particular run generated the following results.

![Experimental Results 1000000](README_assets/Experimental Results 1000000.png)\
<BR />
When rerun with sample sizes of 3,000,000 and then 9,000,000 records, the following results can be observed for comparison.  For clarity, many of the metrics are hidden to make the observations more easily observed:

![Experimental Results Comparisons](README_assets/Experimental Results Comparisons.png)\
<BR />
