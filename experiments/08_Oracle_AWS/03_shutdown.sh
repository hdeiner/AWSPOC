#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 200 -f small "Shutdown Oracle AWS"
terraform destroy -var rows=$(<.rows) -auto-approve
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "08_Oracle_AWS: Shutdown Oracle AWS" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .rows .script .results terraform.aws_instance.tf Experimental\ Results.csv

../../endExperiment.sh