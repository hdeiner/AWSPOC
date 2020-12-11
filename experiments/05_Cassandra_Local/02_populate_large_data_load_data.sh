#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Cassandra Data - Large Data - $ROWS rows"
head -n `echo "$ROWS+1" | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_transfer_of_Val/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
head -n 1 /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv > .columns

echo "COPY PGYR19_P063020.PI " > .command
echo " ($(<.columns)) " >> .command
echo " FROM '/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv' " >> .command
echo " WITH DELIMITER=',' " >> .command
echo " AND DATETIMEFORMAT='%m/%d/%Y' " >> .command
echo " AND NULL='n/a' " >> .command
echo " AND HEADER=TRUE " >> .command

docker cp /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv cassandra_container:/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker exec cassandra_container cqlsh -e "$(<.command)"
#docker exec cassandra_container cqlsh -e "ALTER TABLE PGYR19_P063020.PI WITH gc_grace_seconds = '0'" # get rid of tombstone
#docker exec cassandra_container nodetool compact # get rid of tombstones
rm .columns .command
