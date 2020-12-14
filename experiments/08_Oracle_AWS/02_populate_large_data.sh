#!/usr/bin/env bash

ROWS=$(</tmp/.rows)
export ROWS

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"
sleep 30s
figlet -w 240 -f small "Populate Oracle AWS - Large Data - $(numfmt --grouping $ROWS) rows"
figlet -w 240 -f small "Apply Schema for Oracle - Large Data - $(numfmt --grouping $ROWS) rows"
cp /tmp/changeset.xml /tmp/changeSet.xml
# make schemaName="PI" in a line go away
sed --in-place --regexp-extended '"'"'s/schemaName\=\"PI\"//g'"'"' /tmp/changeSet.xml
cd /tmp ; java -jar liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@localhost:1521/ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc8.jar" --changeLogFile=changeSet.xml update
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Populate Oracle Schema "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results /tmp/changeSet.xml Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
/tmp/transferPGYR19_P063020_from_s3_and_decrypt.sh > /dev/null
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Get Data from S3 Bucket "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

{ time /tmp/02_populate_large_data_load_data.sh $ROWS; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Populate Oracle Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm -rf /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Oracle Data - Large Data - $(numfmt --grouping $ROWS) rows"

echo ""
echo "First two rows of data"
echo "SET LINESIZE 240; " > /tmp/command.sql
echo "SET WRAP OFF;" >> /tmp/command.sql
echo "SET TRIMSPOOL ON;" >> /tmp/command.sql
echo "SET TRIMOUT ON;" >> /tmp/command.sql
echo "select * from "OP_DTL_GNRL_PGYR2019_P06302020" FETCH FIRST 2 ROWS ONLY;" >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "Count of rows of data"
echo "SET LINESIZE 240; " > /tmp/command.sql
echo "SET WRAP OFF;" >> /tmp/command.sql
echo "SET TRIMSPOOL ON;" >> /tmp/command.sql
echo "SET TRIMOUT ON;" >> /tmp/command.sql
echo "select count(*) from "OP_DTL_GNRL_PGYR2019_P06302020";" >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "Average of total_amount_of_payment_usdollars"
echo "SET LINESIZE 240; " > /tmp/command.sql
echo "SET WRAP OFF;" >> /tmp/command.sql
echo "SET TRIMSPOOL ON;" >> /tmp/command.sql
echo "SET TRIMOUT ON;" >> /tmp/command.sql
echo "COLUMN change_type FORMAT A12;" >> /tmp/command.sql
echo "COLUMN covered_recipient_type FORMAT A20;" >> /tmp/command.sql
echo "COLUMN teaching_hospital_name FORMAT A20;" >> /tmp/command.sql
echo "select avg(total_amount_of_payment_usdollars) from OP_DTL_GNRL_PGYR2019_P06302020;" >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
echo ""
echo "Top ten earning physicians"
echo "SET LINESIZE 240; " > /tmp/command.sql
echo "SET WRAP OFF; " >> /tmp/command.sql
echo "SET TRIMSPOOL ON; " >> /tmp/command.sql
echo "SET TRIMOUT ON; " >> /tmp/command.sql
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars) " >> /tmp/command.sql
echo "FROM OP_DTL_GNRL_PGYR2019_P06302020 " >> /tmp/command.sql
echo "WHERE physician_first_name IS NOT NULL " >> /tmp/command.sql
echo "AND physician_last_name IS NOT NULL " >> /tmp/command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> /tmp/command.sql
echo "ORDER BY SUM(total_amount_of_payment_usdollars) DESC " >> /tmp/command.sql
echo "FETCH FIRST 10 ROWS ONLY; " >> /tmp/command.sql
sudo -u oracle bash -c "source /home/oracle/.bash_profile ; cat /tmp/command.sql | sqlplus system/OraPasswd1@localhost:1521/ORCL | sed -r '"'"'s/(^.{240})(.*)/\1/'"'"' | sed -E '"'"'/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|SQL\>|^$/d'"'"'"
EOF'
chmod +x /tmp/.script
{ time /tmp/.script; } 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "08_Oracle_AWS: Check Oracle Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm -rf /tmp/.script /tmp/.results /tmp/command.sql /tmp/*.csv /tmp/PGYR19_P063020