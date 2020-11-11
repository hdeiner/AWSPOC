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
    source      = "../../data/oracle/ce.Clinical_Condition.csv"
    destination = "/tmp/ce.Clinical_Condition.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.DerivedFact.csv"
    destination = "/tmp/ce.DerivedFact.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.DerivedFactProductUsage.csv"
    destination = "/tmp/ce.DerivedFactProductUsage.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.MedicalFinding.csv"
    destination = "/tmp/ce.MedicalFinding.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.MedicalFindingType.csv"
    destination = "/tmp/ce.MedicalFindingType.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.OpportunityPointsDiscr.csv"
    destination = "/tmp/ce.OpportunityPointsDiscr.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.ProductFinding.csv"
    destination = "/tmp/ce.ProductFinding.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.ProductFindingType.csv"
    destination = "/tmp/ce.ProductFindingType.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.ProductOpportunityPoints.csv"
    destination = "/tmp/ce.ProductOpportunityPoints.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../data/oracle/ce.Recommendation.csv"
    destination = "/tmp/ce.Recommendation.csv"
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
sudo apt install -y -qq openjdk-8-jdk wget unzip awscli >> provision.log

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
The script that is run on the EC2 instance (02_populate.sh) is also worthy of note, as it runs on each instance in the Ignite cluster.  It has to see if another cluster has already defined the schema and then if another instance has loaded data into the cluster.
```bash
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 160 -f small "Populate Ignite Schema AWS Cluster"
echo '!tables' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE 'SQL_CE_' .results)
if [ $result == 0 ] ; then
  ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql
fi

echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.Clinical_Condition.csv
  echo 'COPY FROM '\'/tmp/ce.Clinical_Condition.csv\'' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.DerivedFact.csv
  echo 'COPY FROM '\'/tmp/ce.DerivedFact.csv\'' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID ) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.DerivedFactProductUsage.csv
  echo 'COPY FROM '\'/tmp/ce.DerivedFactProductUsage.csv\'' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -ir 's/ *|/|/g' /tmp/ce.MedicalFinding.csv   # remove blanks before |
  sed -ir 's/| */|/g' /tmp/ce.MedicalFinding.csv   # remove blanks after |
  sed -ir 's/^ *//g' /tmp/ce.MedicalFinding.csv    # remove beining of line blanks
  # some of the input fields have commas - must properly make them suitable for csv import
  sed -i 's/,/:/g' /tmp/ce.MedicalFinding.csv      # change commas to colons
  sed -i 's/|/,/g' /tmp/ce.MedicalFinding.csv      # change bars to commas
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.MedicalFinding.csv\'' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.MedicalFindingType.csv
  echo 'COPY FROM '\'/tmp/ce.MedicalFindingType.csv\'' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.OpportunityPointsDiscr.csv
  echo 'COPY FROM '\'/tmp/ce.OpportunityPointsDiscr.csv\'' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductFinding.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductFinding.csv\'' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductFindingType.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductFindingType.csv\'' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductOpportunityPoints.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductOpportunityPoints.csv\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

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
```
This is what the console looks like when the script is executed.  It takes about 12 minutes, is completely repeatable, and doesn't require any manual intervention.  
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
![03_shutdown_console_01](README_assets/03_shutdown_console_01.png)\
<BR/>
