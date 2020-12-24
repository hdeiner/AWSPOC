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