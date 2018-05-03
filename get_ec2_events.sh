#!/bin/bash

##
# get_ec2_events.sh
#
# gets instance status for all ec2 instances in a region, same data as in the EC2 Events console
#
# Copyright Brandon Burton, 2015
#
# v0.1.1
#
##

if [ -n "$1" ]
then
  ACCOUNT=$1
else
  ACCOUNT="default"
fi
if [ -n "$2" ]
then
  if [[ $2 == "--all" ]]
  then
    EVENT_FILTER_COMPLETED="true"
  fi
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EC2_REGIONS="${EC2_REGIONS:-$(aws --profile $ACCOUNT ec2 describe-regions --region us-west-2 --output text | cut -f 3)}"

echo "Getting instances for profile $ACCOUNT"

describe_instance_status() {

  instance=$1
  region=$2
  # The default behavior is now to filter on Completed, unless you include --all
  if [[ $EVENT_FILTER_COMPLETED == "true" ]]
  then
    aws ec2 describe-instance-status --profile $ACCOUNT --region $region --output text --instance-ids $instance \
      --filters "Name=event.code,Values=instance-reboot,system-reboot,system-maintenance,instance-retirement,instance-stop" \
      | grep -i EVENTS
  else
    aws ec2 describe-instance-status --profile $ACCOUNT --region $region --output text --instance-ids $instance \
      --filters "Name=event.code,Values=instance-reboot,system-reboot,system-maintenance,instance-retirement,instance-stop" \
      | grep -i EVENTS | grep -v -E 'Completed|Canceled'
  fi
}

instance_name() {
  instance_id=$1
  region=$2
  aws ec2 describe-instances --profile $ACCOUNT --region $region --output text --instance-id $instance_id | grep -i TAGS | cut -f 3
}

for region in $EC2_REGIONS; do
  echo "Region: $region"

  # get a list of all instances in the region that are running (instance-state-code:16)
  # * http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
  EC2_INSTANCE_LIST=$(aws ec2 describe-instances --profile $ACCOUNT --region $region \
    --filters "Name=instance-state-code,Values=16" \
    | grep InstanceId | cut -d ':' -f 2 | cut -d '"' -f 2)

  if [[ -z $EC2_INSTANCE_LIST ]]; then
    echo "no running instances found"
  else
    echo "found instances, getting status"
    for instance in $EC2_INSTANCE_LIST; do
      # get the instance status, we only want instances with the following statuses
      # * instance-reboot
      # * system-reboot
      # * system-maintenance
      # * instance-retirement
      instance_status=$(describe_instance_status $instance $region | awk -v OFS="::" '$1=$1')
      # only if it matches do we save the data
      if [[ ! -z $instance_status ]]; then
        instance_details="Instance_ID:$instance, \
          Instance_Name:$(instance_name $instance $region), \
          Instance_Status:$instance_status"
        instance_found=$(echo "$instance_details" | tr -d '\040')
        echo $instance_found
        echo $instance_found >> "$ACCOUNT"_"$region"_found_instances_"$TIMESTAMP".csv
      fi
    done
  fi
done


