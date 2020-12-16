#!/usr/bin/env bash

cp terraform.aws_instance.tf.original terraform.aws_instance.tf

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Startup MongoDB AWS"
terraform init
echo "ALL" > .rows
terraform apply -var rows=$(<.rows) -auto-approve
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "10_MongoDB_AWS: Startup MongoDB AWS" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv