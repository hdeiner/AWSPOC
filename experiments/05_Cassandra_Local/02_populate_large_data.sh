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

figlet -w 240 -f small " Populate Cassandra Locally - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small " Populate Cassandra Locally"

figlet -w 240 -f small "Apply Schema for Cassandra - Large Data - $(numfmt --grouping $ROWS) rows"
docker exec cassandra_container cqlsh -e "CREATE KEYSPACE IF NOT EXISTS PGYR19_P063020 WITH replication = {'"'"'class'"'"': '"'"'SimpleStrategy'"'"', '"'"'replication_factor'"'"' : 1}"
docker exec cassandra_container cqlsh -e "$(<../../ddl/PGYR19_P063020/changeset.cassandra.sql)"

EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "05_Cassandra_Local: Populate Cassandra Schema - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results  Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "05_Cassandra_Local: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

command time -v ./02_populate_large_data_load_data.sh $ROWS 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "05_Cassandra_Local: Populate Cassandra Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Cassandra Data - Large Data - $(numfmt --grouping $ROWS) rows"
echo ""
echo "First two rows of data"
docker exec cassandra_container cqlsh -e "select * from PGYR19_P063020.PI LIMIT 2;" 2> /dev/tty
echo ""
echo "Count of rows of data"
docker exec cassandra_container cqlsh -e "select count(*) from PGYR19_P063020.PI;" 2> /dev/tty
echo ""
echo "Average of total_amount_of_payment_usdollars"
docker exec cassandra_container cqlsh -e "select avg(total_amount_of_payment_usdollars) from PGYR19_P063020.PI;" 2> /dev/tty
echo ""
echo "Top ten earning physicians"
docker exec cassandra_container cqlsh -e "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars) FROM PGYR19_P063020.PI WHERE physician_first_name IS NOT NULL AND physician_last_name IS NOT NULL GROUP BY physician_first_name, physician_last_name ORDER BY SUM(total_amount_of_payment_usdollars) DESC LIMIT 10;" 2> /dev/tty
EOF'

chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "05_Cassandra_Local: Check Cassandra Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .sql .results *.csv /tmp/PGYR19_P063020
