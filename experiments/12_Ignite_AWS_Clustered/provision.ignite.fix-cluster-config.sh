#!/usr/bin/env bash

aws ec2 describe-instances --region "us-east-1" --query 'Reservations[].Instances[].[Placement.AvailabilityZone,State.Name,Tags[0].Value,PrivateIpAddress,PublicIpAddress]' --output text > .instances
instance_file=".instances"

template_file="provision.ignite.cluster-config.xml"
while IFS= read -r template_line
do
	TEMPLATE_LINE=$(echo $template_line | xargs -0)
	if [ "$TEMPLATE_LINE" == "<value>1.2.3.4</value>" ];
	then
		while IFS= read -r instance_line
		do
			STATE=$(echo "$instance_line" | awk -F"\t" '{print $2}')
			if [ $STATE == "running" ];
			then
				PRIVATE_IP=`echo "$instance_line" | awk -F"\t" '{print $4}'`
				printf '                                <value>%s</value>\n' "$PRIVATE_IP"
			fi
		done <"$instance_file"
	else
		printf '%s\n' "$template_line"
	fi
done <"$template_file"
