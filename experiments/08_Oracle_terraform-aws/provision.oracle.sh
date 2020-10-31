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
sudo yum install oracle-database-server-12cR2-preinstall zip unzip awscli java-1.8.0-openjdk -q -y

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

