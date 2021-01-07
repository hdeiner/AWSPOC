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

figlet -w 240 -f small "Populate Hive Locally - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small "Apply Schema for Hive - Large Data - $(numfmt --grouping $ROWS) rows"
docker cp ../../ddl/PGYR19_P063020/changeset.hive.sql hive-server:/tmp/changeset.hive.sql
docker exec -it hive-server bash -c "beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --autoCommit=true -f /tmp/changeset.hive.sql"
echo ""
docker exec -it hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --autoCommit=true -e '"'"'show tables;'"'"'"
echo ""
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "13_Hive_Local: Populate Hive Schema - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
python3 ../../create_csv_data_PGYR2019_P06302020.py -s $ROWS -i /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv -o /tmp/PGYR2019_P06302020.csv
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "13_Hive_Local: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

command time -v ./02_populate_large_data_load_data.sh $ROWS 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "13_Hive_Local: Populate Hive Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Hive Data - Large Data - $(numfmt --grouping $ROWS) rows"
echo ""
echo "Location of data in Hadoop"
docker exec hive-server bash -c "hdfs dfs -ls -h /user/hive/warehouse/pgyr2019_p06302020/PGYR2019_P06302020.csv"
echo ""
echo "First two rows of data"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e '"'"'SELECT * FROM PGYR2019_P06302020 LIMIT 2;'"'"'"
echo ""
echo "Count of rows of data"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e '"'"'SELECT COUNT(*) AS count_of_rows_of_data FROM PGYR2019_P06302020;'"'"'"
echo ""
echo "Average of total_amount_of_payment_usdollars"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='"'"'###,###,###,##0.00'"'"' --silent -e '"'"'SELECT AVG(total_amount_of_payment_usdollars) AS average_of_total_amount_of_payment_usdollars FROM PGYR2019_P06302020;'"'"'"
echo ""
echo "Top ten earning physicians"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars) AS sum_of_payments" > .command.sql
echo "FROM PGYR2019_P06302020 " >> .command.sql
echo "WHERE physician_first_name != '"'"''"'"' "  >> .command.sql
echo "AND physician_last_name != '"'"''"'"' " >> .command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> .command.sql
echo "ORDER BY sum_of_payments DESC " >> .command.sql
echo "LIMIT 10; " >> .command.sql
docker cp .command.sql hive-server:/tmp/command.sql
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='"'"'###,###,###,##0.00'"'"' --silent -f /tmp/command.sql"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "13_Hive_Local: Check Hive Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results .command.sql *.csv /tmp/PGYR19_P063020 /tmp/PGYR2019_P06302020.csv