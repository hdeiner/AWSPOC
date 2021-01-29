#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Test Hive$(tput sgr 0)"
echo "$(tput bold)$(tput smul)$(tput setaf 6)This is run on AWS ONLY during startup$(tput sgr 0)"

source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Get CMS Complete 2019 Program Year Dataset from https://download.cms.gov/openpayments/PGYR19_P063020.ZIP$(tput sgr 0)"
curl --connect-timeout 30 --retry 100 --retry-delay 5 "https://download.cms.gov/openpayments/PGYR19_P063020.ZIP" -o /tmp/PGYR19_P063020.ZIP
unzip  /tmp/PGYR19_P063020.ZIP -d /tmp/PGYR19_P063020
echo "$(tput bold)$(tput setaf 6)Create CSV Format for Hive Ingest$(tput sgr 0)"
ROWS=$(cat /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv | wc -l)
python3 /tmp/create_csv_data_PGYR2019_P06302020.py -s $ROWS -i /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv -o /tmp/PGYR2019_P06302020.csv

echo "$(tput bold)$(tput setaf 6)Apply Schema$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --autoCommit=true -f /tmp/PGYR2019_P06302020.schema.sql

echo "$(tput bold)$(tput setaf 6)Import Data$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --autoCommit=true -f /tmp/PGYR2019_P06302020.load_data.sql

echo "$(tput bold)$(tput setaf 6)Work With Hive$(tput sgr 0)"

echo "$(tput bold)$(tput setaf 6)Location of data in Hadoop$(tput sgr 0)"
$HADOOP_HOME/bin/hdfs dfs -ls -h /user/hive/warehouse/pgyr2019_p06302020/

echo "$(tput bold)$(tput setaf 6)First two rows of data$(tput sgr 0)"
echo "SELECT * FROM PGYR2019_P06302020 LIMIT 2;" > /tmp/command.sql
echo "$(tput bold)$(tput setaf 6)$(cat /tmp/command.sql)$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --maxWidth=200 --maxColumnWidth=20 --truncateTable=true --silent -f /tmp/command.sql

echo "$(tput bold)$(tput setaf 6)Count of rows of data$(tput sgr 0)"
echo "SELECT COUNT(*) AS count_of_rows_of_data FROM PGYR2019_P06302020;" > /tmp/command.sql
echo "$(tput bold)$(tput setaf 6)$(cat /tmp/command.sql)$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --maxWidth=200 --maxColumnWidth=20 --truncateTable=true --silent -f /tmp/command.sql

echo "$(tput bold)$(tput setaf 6)Average of total_amount_of_payment_usdollars$(tput sgr 0)"
echo "SELECT AVG(total_amount_of_payment_usdollars) AS average_of_total_amount_of_payment_usdollars FROM PGYR2019_P06302020;" > /tmp/command.sql
echo "$(tput bold)$(tput setaf 6)$(cat /tmp/command.sql)$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --maxWidth=200 --maxColumnWidth=20 --truncateTable=true --numberFormat='"'"'###,###,###,##0.00'"'"' --silent -f /tmp/command.sql

echo "$(tput bold)$(tput setaf 6)Top ten earning physicians$(tput sgr 0)"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars) AS sum_of_payments" > /tmp/command.sql
echo "FROM PGYR2019_P06302020 " >> /tmp/command.sql
echo "WHERE physician_first_name != '' "  >> /tmp/command.sql
echo "AND physician_last_name != '' " >> /tmp/command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> /tmp/command.sql
echo "ORDER BY sum_of_payments DESC " >> /tmp/command.sql
echo "LIMIT 10; " >> /tmp/command.sql
echo "$(tput bold)$(tput setaf 6)$(cat /tmp/command.sql)$(tput sgr 0)"
beeline -u 'jdbc:hive2://127.0.0.1:10000/' --color=true --maxWidth=200 --maxColumnWidth=20 --truncateTable=true --numberFormat='###,###,###,##0.00' --silent -f /tmp/command.sql