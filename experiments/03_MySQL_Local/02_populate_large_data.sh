#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo "must supply the command with the number of rows to use"
    exit 1
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
    echo "must supply the command with the number of rows to use"
   exit 1
fi

ROWS=$1
export ROWS

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash

echo $1

figlet -w 240 -f small "Populate MySQL Locally - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small "Apply Schema for MySQL - Large Data - $(numfmt --grouping $ROWS) rows"
docker exec mysql_container echo '"'"'CREATE DATABASE PI;'"'"' | mysql -h 127.0.0.1 -P 3306 -u root --password=password
liquibase --changeLogFile=../../ddl/PGYR19_P063020/changeset.xml --url='"'"'jdbc:mysql://localhost:3306/PI?autoReconnect=true&verifyServerCertificate=false&useSSL=false'"'"' --username=root --password=password  --driver=org.gjt.mm.mysql.Driver --classpath=../../liquibase_drivers/mysql-connector-java-5.1.48.jar update
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "03_MySQL_Local: Populate MySQL Schema - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "03_MySQL_Local: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

command time -v ./02_populate_large_data_load_data.sh $ROWS 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "03_MySQL_Local: Populate MySQL Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check MySQL Data - Large Data - $(numfmt --grouping $ROWS) rows"
echo ""
echo "First two rows of data"
docker exec mysql_container echo '"'"'select * from PI.OP_DTL_GNRL_PGYR2019_P06302020 LIMIT 2;'"'"' | mysql -h 127.0.0.1 -P 3306 -u root --password=password PI
echo ""
echo "Count of rows of data"
docker exec mysql_container echo '"'"'select count(*) from PI.OP_DTL_GNRL_PGYR2019_P06302020 LIMIT 2;'"'"' | mysql -h 127.0.0.1 -P 3306 -u root --password=password PI
echo ""
echo "Average of total_amount_of_payment_usdollars"
docker exec mysql_container echo '"'"'select avg(total_amount_of_payment_usdollars) from PI.OP_DTL_GNRL_PGYR2019_P06302020;'"'"' | mysql -h 127.0.0.1 -P 3306 -u root --password=password PI
echo ""
echo "Top ten earning physicians"
docker exec mysql_container echo '"'"'SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars) FROM PI.OP_DTL_GNRL_PGYR2019_P06302020 WHERE physician_first_name IS NOT NULL AND physician_last_name IS NOT NULL GROUP BY physician_first_name, physician_last_name ORDER BY SUM(total_amount_of_payment_usdollars) DESC LIMIT 10;'"'"' | mysql -h 127.0.0.1 -P 3306 -u root --password=password PI
EOF'

chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "03_MySQL_Local: Check MySQL Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .sql .results *.csv /tmp/PGYR19_P063020