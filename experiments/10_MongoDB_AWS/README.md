### Starting out with AWS MongoDB

##### Concept

> MongoDB is a cross-platform document-oriented database program. Classified as a NoSQL database program, MongoDB uses JSON-like documents with optional schemas. MongoDB is developed by MongoDB Inc. and licensed under the Server Side Public License (SSPL).

> https://en.wikipedia.org/wiki/PostgreSQL

> https://www.mongodb.com

#### Execution

### 01_startup.sh
This script uses simple Terraform and applies it.   
```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Startup MongoDB AWS"
terraform init
terraform apply -auto-approve
```
The terraform.aws_instance.tf is the most interesting of the terraform scripts because it does does all of the heavy lifting through provisiong.

The reason for doing the provisioning of the actual database and loading sample data is that I don't want to install local clients on the invoking machine.
```hcl-terraform
resource "aws_instance" "mongodb_ec2_instance" {
  ami = "ami-0ac80df6eff0e70b5"  #  Ubuntu 18.04 LTS - Bionic - hvm:ebs-ssde  https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "m5.large"   # $0.096/hour ; 2 vCPU  ; 10 ECU  ; 8 GiB memory   ; EBS disk              ; EBS Optimized by default
#  instance_type = "m5d.metal" # $5.424/hour ; 96 vCPU ; 345 ECU ; 384 GiB memory ; 4 x 900 NVMe SSD disk ; EBS Optimized by default ; max bandwidth 19,000 Mbps ; max throughput 2,375 MB/s ; Max IOPS 80,000
  key_name = aws_key_pair.mongodb_key_pair.key_name
  ebs_optimized = true
  security_groups = [aws_security_group.mongodb.name]
  root_block_device {
    volume_type           = "io1"
    volume_size           = 30 # GB
    iops                  = 500
    delete_on_termination = true
  }
  count = 1
  tags = {
    Name = "MongoDB Instance ${format("%03d", count.index)}"
  }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --region ${regex("[a-z]+[^a-z][a-z]+[^a-z][0-9]+",self.availability_zone)} --instance-ids ${aws_instance.mongodb_ec2_instance[count.index].id}"
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
    source      = "../../src/db/DERIVEDFACT.csv"
    destination = "/tmp/DERIVEDFACT.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/MEMBERHEALTHSTATE.csv"
    destination = "/tmp/MEMBERHEALTHSTATE.csv"
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
The script that is run on the EC2 instance (provision.mongodb.sh) does the provisioning of the database itself.
```bash
#!/usr/bin/env bash

sleep 15

sudo apt-get update
sudo apt-get install -y -qq figlet

figlet -w 160 -f small "Install Prerequisites"
sudo apt-get install -y -qq gnupg

figlet -w 160 -f small "Import MongoDB public GPG Key"
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

figlet -w 160 -f small "Create list file for MongoDB"
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

figlet -w 160 -f small "Install MongoDB packages"
sudo apt-get update
sudo apt-get install -y -qq mongodb-org

figlet -w 160 -f small "Start MongoDB"
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl enable mongod

figlet -w 160 -f small "Verify That MongoDB Is Up"
echo -e `sudo systemctl status mongod`
```
The script that is then run on the EC2 instance (02_populate.sh) uses mongoimport to bring in the data and mongo to report on it.
```bash
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 160 -f small "Populate MongoDB AWS"
mongoimport --type csv -d testdatabase -c DERIVEDFACT --headerline /tmp/DERIVEDFACT.csv
mongoimport --type csv -d testdatabase -c MEMBERHEALTHSTATE --headerline /tmp/MEMBERHEALTHSTATE.csv

figlet -w 160 -f small "Check MongoDB AWS"
echo 'use testdatabase' > /tmp/.mongo.js
echo 'db.DERIVEDFACT.find()' >> /tmp/.mongo.js
echo 'db.MEMBERHEALTHSTATE.find()' >> /tmp/.mongo.js
echo 'exit' >> /tmp/.mongo.js

mongo < /tmp/.mongo.js
```
This is what the console looks like when the script is executed.  It takes about 4 minutes, is completely repeatable, and doesn't require any manual intervention.  
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
<BR/>
If we were to peruse the AWS Console EC2 Dashboard, here's what we will see.
![01_startup_aws_console_ec2_dashboard_01](README_assets/01_startup_aws_console_ec2_dashboard_01.png)\
<BR/>
Looking at the running instances, we see
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
This script was run on the AWS EC2 instance in the 01_startup.sh for this experiment to avoid having to install MongoDB clients on our local machine.
<BR/>
### 03_shutdown.sh
This script is extremely simple.  It tells terraform to destroy all that it created.

```bash
#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown MongoDB AWS"
terraform destroy -auto-approve
```
The console shows what it does.
![03_shutdown_console_01](README_assets/03_shutdown_console_01.png)\
<BR/>
