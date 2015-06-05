#!/bin/sh

REGION=${1-us-east-1}
aws --region ${REGION} autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].AutoScalingGroupName' | sed 's/[^A-Za-z0-9\-]//g'

