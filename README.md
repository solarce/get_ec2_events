get_ec2_events.sh
-----------------

aka [*ballin-nemisis*](https://twitter.com/solarce/status/571488994724356096)

Requirements
============

1. You must have [awscli](http://aws.amazon.com/cli/) installed, e.g. `pip install awscli --upgrade`
2. You need to [configure the awscli](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), potentially with multiple profiles

Description
===========

Uses the `awscli` tool to get a list of ec2 instances from a region and return a list of systems with one of the following event types:

* instance-reboot
* system-reboot
* system-maintenance
* instance-retirement

Usage
=====

Grab the [latest release](https://github.com/solarce/get_ec2_events/releases) of the script and make it executable.

```chmod +x get_ec2_events.sh```

The script uses whatever credentials you've configured in `~/.aws/config` unless you pass it a [profile name](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles).

The script now filters Events that are `Completed` or `Canceled` by
default. Add `--all` to have it print out all instances.

Run the script like:

```
./get_ec2_events.sh PROFILE_NAME

[bburton@althalus] ~/code/get_ec2_events_github >> ./get_ec2_events.sh solarce_aws
Getting instances for profile solarce_aws
Region: eu-central-1
no running instances found
Region: sa-east-1
no running instances found
Region: ap-northeast-1
no running instances found
Region: eu-west-1
no running instances found
Region: us-east-1
found instances, getting status
Instance_ID:i-XXXXXXXX,Instance_Name:git.repo,Instance_Status:EVENTS::system-reboot::Scheduled::reboot::2015-03-08T04:00:00.000Z::2015-03-07T23:00:00.000Z
Instance_ID:i-XXXXXXXX,Instance_Name:keymaster,Instance_Status:EVENTS::system-reboot::Scheduled::reboot::2015-03-07T14:00:00.000Z::2015-03-07T09:00:00.000Z
Region: us-west-1
no running instances found
Region: us-west-2
no running instances found
Region: ap-southeast-2
no running instances found
Region ap-southeast-1
no running instances found
```

The script will also write the data to a *.csv* file, named like `solarce_aws_us-east-1_found_instances_20150227_180338.csv`

To limit the regions the script searches, set the EC2_REGIONS environment variable:

```
EC2_REGIONS="us-west-2 us-east-1" ./get_ec2_events.sh PROFILE_NAME
```

Authors
=======

Created and maintained by [Brandon Burton](https://github.com/solarce) (brandon@inatree.org).

License
=======

Apache 2 licensed.
See LICENSE for full details.

