#!/usr/bin/env bash

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
echo "yum update"
sudo yum update -q -y > provision.log
echo "yum install wget gcc make awscli perl gnupg gnupg2"
sudo yum install wget gcc make awscli perl gnupg gnupg2 -q -y >> provision.log

echo "create figlet"
wget ftp://ftp.figlet.org/pub/figlet/program/unix/figlet-2.2.5.tar.gz --quiet
tar -xf figlet-2.2.5.tar.gz >> provision.log
cd figlet-2.2.5
sudo make install > figlet.log 2>&1
cd ..
rm -rf figlet-2.2.5 figlet-2.2.5.tar.gz

figlet -w 240 -f small "Install Oracle Prerequisites"
sudo yum install oracle-database-server-12cR2-preinstall zip unzip gnupg gnupg2 awscli java-1.8.0-openjdk -q -y >> provision.log

echo "Create Oracle User"
sudo echo -e "FuckMeAgain\nFuckMeAgain" | sudo passwd oracle
sudo mkdir -p /u01/software
sudo chown -R oracle:oinstall /u01
sudo chmod -R 775 /u01

echo "Fix Oracle 12 bash_profile"
echo '"'"'# Oracle specific environment and startup programs'"'"' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo '"'"'export ORACLE_HOME=/u01/app/oracle/product/12.2.0.1.0/dbhome_1'"'"' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo '"'"'export ORACLE_SID=ORCL'"'"' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo '"'"'PATH=$PATH:$HOME/.local/bin:$ORACLE_HOME/bin'"'"' | sudo tee -a /home/oracle/.bash_profile > /dev/null
echo '"'"'export PATH'"'"' | sudo tee -a /home/oracle/.bash_profile > /dev/null
sudo chown oracle /home/oracle

echo "Setup Oracle for AWS CLI"
sudo mkdir /home/oracle/.aws
sudo cp -R /home/ec2-user/.aws/* /home/oracle/.aws/.

echo "Setup Oracle for ssh"
sudo mkdir /home/oracle/.ssh
sudo cp /home/ec2-user/.ssh/authorized_keys /home/oracle/.ssh/.

echo "Run Oracle 12 Setup"
# get the public dns in for the hostname
echo ORACLE_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname --silent` >> provision.oracle.response.file.rsp

sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cd /u01/software ; aws s3 cp --quiet s3://health-engine-aws-poc/linuxx64_12201_database.zip linuxx64_12201_database.zip ; unzip -qq linuxx64_12201_database.zip ; rm linuxx64_12201_database.zip ; cd /u01/software/database ; ./runInstaller -waitForCompletion -showProgress -silent -ignoreSysPrereqs -responseFile /tmp/provision.oracle.response.file.rsp" >> provision.log

echo "Finish Oracle 12 Setup as root"

sudo /u01/app/oraInventory/orainstRoot.sh >> provision.log
sudo /u01/app/oracle/product/12.2.0.1.0/dbhome_1/root.sh >> provision.log

echo "DBCA Oracle Database"
#sudo -u oracle bash -c "source /home/oracle/.bash_profile ; dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname cdb1 -sid cdb1 -responseFile NO_VALUE -characterSet AL32UTF8 -sysPassword OraPasswd1 -systemPassword OraPasswd1 -createAsContainerDatabase true -numberOfPDBs 1 -pdbName pdb1 -pdbAdminPassword OraPasswd1 -databaseType MULTIPURPOSE -automaticMemoryManagement false -storageType FS -ignorePreReqs"
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname ORCL -sid ORCL -responseFile NO_VALUE -characterSet AL32UTF8 -sysPassword OraPasswd1 -systemPassword OraPasswd1 -createAsContainerDatabase true -numberOfPDBs 1 -pdbName ORCLPDB -pdbAdminPassword OraPasswd1 -databaseType MULTIPURPOSE -automaticMemoryManagement false -createListener ORCL -storageType FS  -datafileDestination "/u01/app/oracle/oradata/" -redoLogFileSize 50  -emConfiguration NONE -ignorePreReqs" >> provision.log

echo "Start Oracle Listener"
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; lsnrctl start" >> provision.log
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; lsnrctl services" >> provision.log
echo "alter system set local_listener = '"'"'(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))'"'"' scope = both;"  > /tmp/command.sql
echo "alter system resister;"  >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1">> provision.log
rm /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; lsnrctl status" >> provision.log
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Install Prerequisites "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results