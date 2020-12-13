#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Oracle Data - Large Data - $ROWS rows"
head -n `echo "$ROWS+1" | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_transfer_of_Val/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker cp /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv oracle_container:/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv

grep -E '<column name=' ../../ddl/PGYR19_P063020/changeset.xml > .columns
sed --in-place --regexp-extended 's/            <column name="//g' .columns
sed --in-place --regexp-extended 's/"\ type=".*/,/g' .columns
sed --in-place --regexp-extended '$ s/,$//g' .columns

echo 'options  ( skip=1 )' > .control.ctl
echo 'load data' >> .control.ctl
echo '  infile "/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv"' >> .control.ctl
echo '  truncate into table "OP_DTL_GNRL_PGYR2019_P06302020"' >> .control.ctl
echo 'fields terminated by ","' >> .control.ctl
echo 'optionally enclosed by '"'"'"'"'"' ' >> .control.ctl
echo 'trailing nullcols' >> .control.ctl
echo '( ' >> .control.ctl
cat .control.ctl .columns > .control.ctl.tmp
mv .control.ctl.tmp .control.ctl
echo ' ) ' >> .control.ctl
sed --in-place --regexp-extended 's/date_of_payment/date_of_payment "to_date(:date_of_payment,'"'"'MM\/DD\/YYYY'"'"')"/g' .control.ctl
sed --in-place --regexp-extended 's/payment_publication_date/payment_publication_date "to_date(:date_of_payment,'"'"'MM\/DD\/YYYY'"'"')"/g' .control.ctl
sed --in-place --regexp-extended 's/contextual_information/contextual_information CHAR(500)/g' .control.ctl

docker cp .control.ctl oracle_container:/ORCL/control.ctl
docker exec oracle_container /u01/app/oracle/product/12.2.0/dbhome_1/bin/sqlldr system/Oradoc_db1@localhost:1521/ORCLCDB.localdomain control=/ORCL/control.ctl log=/ORCL/control.log | sed -E '/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'

rm .columns .command .control.ctl