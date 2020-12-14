#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Oracle AWS - Large Data - $ROWS rows"
head -n `echo "$ROWS+1" | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_transfer_of_Val/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv

grep -E '<column name=' /tmp/changeset.xml > /tmp/.columns
sed --in-place --regexp-extended 's/            <column name="//g' /tmp/.columns
sed --in-place --regexp-extended 's/"\ type=".*/,/g' /tmp/.columns
sed --in-place --regexp-extended '$ s/,$//g' /tmp/.columns

echo 'options  ( skip=1 )' > /tmp/control.ctl
echo 'load data' >> /tmp/control.ctl
echo '  infile "/tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv"' >> /tmp/control.ctl
echo '  truncate into table "OP_DTL_GNRL_PGYR2019_P06302020"' >> /tmp/control.ctl
echo 'fields terminated by ","' >> /tmp/control.ctl
echo 'optionally enclosed by '"'"'"'"'"' ' >> /tmp/control.ctl
echo 'trailing nullcols' >> /tmp/control.ctl
echo '( ' >> /tmp/control.ctl
cat /tmp/control.ctl /tmp/.columns > /tmp/control.ctl.tmp
mv /tmp/control.ctl.tmp /tmp/control.ctl
echo ' ) ' >> /tmp/control.ctl
sed --in-place --regexp-extended 's/date_of_payment/date_of_payment "to_date(:date_of_payment,'"'"'MM\/DD\/YYYY'"'"')"/g' /tmp/control.ctl
sed --in-place --regexp-extended 's/payment_publication_date/payment_publication_date "to_date(:date_of_payment,'"'"'MM\/DD\/YYYY'"'"')"/g' /tmp/control.ctl
sed --in-place --regexp-extended 's/contextual_information/contextual_information CHAR(500)/g' /tmp/control.ctl

sudo -u oracle bash -c "source /home/oracle/.bash_profile ; sqlldr system/OraPasswd1@localhost:1521/ORCL control=/tmp/control.ctl log=/tmp/control.log | sed -E '/Loader:|Commit point reached|Copyright|Path used:|Loader:|Commit point reached|Copyright|Path used:|Check the log file:|control.log|for more information about the load|^$/d'"

rm /tmp/.columns /tmp/control.ctl