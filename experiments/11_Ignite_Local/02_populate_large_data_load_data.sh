#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Ignite Data - Large Data - $ROWS rows"

sed -n 1,1p /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > .columns
sed --in-place --regexp-extended 's/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g' .columns
sed --in-place --regexp-extended 's/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Val/g' .columns

docker cp /tmp/PGYR2019_P06302020.csv ignite_container:/tmp/PGYR2019_P06302020.csv
docker exec ignite_container bash -c 'echo "COPY FROM '"'"'/tmp/PGYR2019_P06302020.csv'"'"' INTO PGYR2019_P06302020('$(<.columns)') FORMAT CSV;" | ./apache-ignite/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1'

rm .columns