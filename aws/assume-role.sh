#!/bin/bash
#
# 

CMD=$@

SOURCE_ACCOUNT_ID=747921819386
ROLE_NAME="SREAccess"
ROLE_SESSION_NAME="katch-bi"

ASSUME_ROLE="arn:aws:iam::${SOURCE_ACCOUNT_ID}:role/${ROLE_NAME}"
TMP_FILE=".temp_credentials"

aws sts assume-role --output json --role-arn ${ASSUME_ROLE} --role-session-name ${ROLE_SESSION_NAME} > ${TMP_FILE}

ACCESS_KEY=$(cat ${TMP_FILE} | jq -r ".Credentials.AccessKeyId")
SECRET_KEY=$(cat ${TMP_FILE} | jq -r ".Credentials.SecretAccessKey")
SESSION_TOKEN=$(cat ${TMP_FILE} | jq -r ".Credentials.SessionToken")
EXPIRATION=$(cat ${TMP_FILE} | jq -r ".Credentials.Expiration")

echo "Retrieved temp access key ${ACCESS_KEY} for role ${ASSUME_ROLE}. Key will expire at ${EXPIRATION}"

AWS_ACCESS_KEY_ID=${ACCESS_KEY} \
AWS_SECRET_ACCESS_KEY=${SECRET_KEY} \
AWS_SESSION_TOKEN=${SESSION_TOKEN} ${CMD}

echo "Cleaning temp files..."
rm -f ${TMP_FILE}

