#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 160 -f small "Populate Ignite Schema AWS Cluster"
echo '!tables' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE 'SQL_CE_' .results)
if [ $result == 0 ] ; then
  ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1 -f /tmp/ddl.sql
fi

echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.Clinical_Condition.csv
  echo 'COPY FROM '\'/tmp/ce.Clinical_Condition.csv\'' INTO SQL_CE_CLINICAL_CONDITION(CLINICAL_CONDITION_COD,CLINICAL_CONDITION_NAM) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.DerivedFact.csv
  echo 'COPY FROM '\'/tmp/ce.DerivedFact.csv\'' INTO SQL_CE_DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID ) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.DerivedFactProductUsage.csv
  echo 'COPY FROM '\'/tmp/ce.DerivedFactProductUsage.csv\'' INTO SQL_CE_DERIVEDFACTPRODUCTUSAGE(DERIVEDFACTPRODUCTUSAGEID,DERIVEDFACTID,PRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -ir 's/ *|/|/g' /tmp/ce.MedicalFinding.csv   # remove blanks before |
  sed -ir 's/| */|/g' /tmp/ce.MedicalFinding.csv   # remove blanks after |
  sed -ir 's/^ *//g' /tmp/ce.MedicalFinding.csv    # remove beining of line blanks
  # some of the input fields have commas - must properly make them suitable for csv import
  sed -i 's/,/:/g' /tmp/ce.MedicalFinding.csv      # change commas to colons
  sed -i 's/|/,/g' /tmp/ce.MedicalFinding.csv      # change bars to commas
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.MedicalFinding.csv\'' INTO SQL_CE_MEDICALFINDING(MEDICALFINDINGID,MEDICALFINDINGTYPECD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.MedicalFindingType.csv
  echo 'COPY FROM '\'/tmp/ce.MedicalFindingType.csv\'' INTO SQL_CE_MEDICALFINDINGTYPE(MEDICALFINDINGTYPECD,MEDICALFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.OpportunityPointsDiscr.csv
  echo 'COPY FROM '\'/tmp/ce.OpportunityPointsDiscr.csv\'' INTO SQL_CE_OPPORTUNITYPOINTSDISCR(OPPORTUNITYPOINTSDISCRCD,OPPORTUNITYPOINTSDISCNM) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductFinding.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductFinding.csv\'' INTO SQL_CE_PRODUCTFINDING(PRODUCTFINDINGID,PRODUCTFINDINGNM,SEVERITYLEVELCD,PRODUCTFINDINGTYPECD,PRODUCTMNEMONICCD,SUBPRODUCTMNEMONICCD,INSERTEDBY) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductFindingType.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductFindingType.csv\'' INTO SQL_CE_PRODUCTFINDINGTYPE(PRODUCTFINDINGTYPECD,PRODUCTFINDINGTYPEDESC) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=false -u jdbc:ignite:thin://127.0.0.1 > .results
result=$(grep -cE ' 0   ' .results)
if [ $result == 1 ] ; then
  sed -i 's/|/,/g' /tmp/ce.ProductOpportunityPoints.csv
  # NOT PULLING IN ALL FIELDS!!
  echo 'COPY FROM '\'/tmp/ce.ProductOpportunityPoints.csv\'' INTO SQL_CE_PRODUCTOPPORTUNITYPOINTS(OPPORTUNITYPOINTSDISCCD) FORMAT CSV;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh -u jdbc:ignite:thin://127.0.0.1
fi

figlet -w 160 -f small "Check Ignite AWS Cluster"
echo 'SELECT TOP 10 * FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_CLINICAL_CONDITION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACT;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_DERIVEDFACTPRODUCTUSAGE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_MEDICALFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_OPPORTUNITYPOINTSDISCR;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDING;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTFINDINGTYPE;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_PRODUCTOPPORTUNITYPOINTS;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1

echo 'SELECT TOP 10 * FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
echo 'SELECT COUNT(*) FROM SQL_CE_RECOMMENDATION;' | ./apache-ignite-2.9.0-bin/bin/sqlline.sh --color=true -u jdbc:ignite:thin://127.0.0.1
