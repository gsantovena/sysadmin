#!/bin/sh

export FILTER=$1
export SERVICE=${2:-Search}
export REGION=${3:-us-east-1}

aws --output text --region ${REGION} ec2 describe-instances --instance-ids $(
  aws --output text --region ${REGION} autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[*].[AutoScalingGroupName,InstanceId]' | 
    grep ${FILTER} | grep ${SERVICE} | 
    awk '{ print $2 }'
  ) --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress]'

