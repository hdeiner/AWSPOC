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

figlet -w 240 -f small "Populate Oracle Locally - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small "Apply Schema for Oracle - Large Data - $(numfmt --grouping $ROWS) rows"
cp ../../ddl/PGYR19_P063020/changeset.xml changeSet.xml
# make schemaName="PI" in a line go away
sed --in-place --regexp-extended '"'"'s/schemaName\=\"PI\"//g'"'"' changeSet.xml
# modify the tablenames in constraints clauses to include the PI in from of the tablemame.
#sed --in-place --regexp-extended '"'"'s/(tableName\=\")([A-Za-z0-9_\-]+)(\"\/>)/\1PI.\2\3/g'"'"' changeSet.xml
liquibase update
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Populate Oracle Schema - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results changeSet.xml Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

command time -v ./02_populate_large_data_load_data.sh $ROWS 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Populate Oracle Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Oracle Data - Large Data - $(numfmt --grouping $ROWS) rows"

echo ""
echo "First two rows of data"
echo "SET LINESIZE 240; " > .command.sql
echo "SET WRAP OFF;" >> .command.sql
echo "SET TRIMSPOOL ON;" >> .command.sql
echo "SET TRIMOUT ON;" >> .command.sql
echo "select * from "OP_DTL_GNRL_PGYR2019_P06302020" FETCH FIRST 2 ROWS ONLY;" >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r "s/(^.{240})(.*)/\1/" | sed -E "/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d"
echo ""
echo "Count of rows of data"
echo "SET LINESIZE 240; " > .command.sql
echo "SET WRAP OFF;" >> .command.sql
echo "SET TRIMSPOOL ON;" >> .command.sql
echo "SET TRIMOUT ON;" >> .command.sql
echo "select count(*) from "OP_DTL_GNRL_PGYR2019_P06302020";" >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r "s/(^.{240})(.*)/\1/" | sed -E "/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d"
echo ""
echo "Average of total_amount_of_payment_usdollars"
echo "SET LINESIZE 240; " > .command.sql
echo "SET WRAP OFF;" >> .command.sql
echo "SET TRIMSPOOL ON;" >> .command.sql
echo "SET TRIMOUT ON;" >> .command.sql
echo "COLUMN change_type FORMAT A12;" >> .command.sql
echo "COLUMN covered_recipient_type FORMAT A20;" >> .command.sql
echo "COLUMN teaching_hospital_name FORMAT A20;" >> .command.sql
echo "select avg(total_amount_of_payment_usdollars) from OP_DTL_GNRL_PGYR2019_P06302020;" >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r "s/(^.{240})(.*)/\1/" | sed -E "/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d"
echo ""
echo "Top ten earning physicians"
echo "SET LINESIZE 240; " > .command.sql
echo "SET WRAP OFF; " >> .command.sql
echo "SET TRIMSPOOL ON; " >> .command.sql
echo "SET TRIMOUT ON; " >> .command.sql
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars) " >> .command.sql
echo "FROM OP_DTL_GNRL_PGYR2019_P06302020 " >> .command.sql
echo "WHERE physician_first_name IS NOT NULL " >> .command.sql
echo "AND physician_last_name IS NOT NULL " >> .command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> .command.sql
echo "ORDER BY SUM(total_amount_of_payment_usdollars) DESC " >> .command.sql
echo "FETCH FIRST 10 ROWS ONLY; " >> .command.sql
docker cp .command.sql oracle_container:/ORCL/command.sql
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlplus system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain @/ORCL/command.sql | sed -r "s/(^.{240})(.*)/\1/" | sed -E "/SQL\*Plus|Copyright|Last Successful login time:|Oracle Database 12c|Connected to:|rows will be truncated|^$/d"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "07_Oracle_Local: Check Oracle Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .sql .results .command.sql *.csv /tmp/PGYR19_P063020