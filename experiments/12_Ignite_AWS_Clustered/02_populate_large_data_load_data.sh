#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Ignite Data - Large Data - $ROWS rows"

sed -n 1,1p /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > .command
sed --in-place --regexp-extended 's/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g' .command
sed --in-place --regexp-extended 's/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Val/g' .command

sed --in-place '1s/^/COPY FROM '"'"'\/tmp\/PGYR2019_P06302020.csv'"'"' INTO PGYR2019_P06302020(/' .command
echo ") FORMAT CSV; " >> .command

./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f .command

rm .command