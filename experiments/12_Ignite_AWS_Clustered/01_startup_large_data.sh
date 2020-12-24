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

cp terraform.aws_instance.tf.large_data terraform.aws_instance.tf

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Startup Ignite AWS" - Large Data - $(numfmt --grouping $ROWS) rows
terraform init
echo "$ROWS" > .rows
terraform apply -var rows=$ROWS -auto-approve
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "12_Ignite_AWS: Startup Ignite AWS" - Large Data - $(numfmt --grouping $ROWS) rows >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
