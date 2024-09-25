#!/bin/bash

source .env

response=$(aws sts assume-role-with-web-identity \
--role-arn $ROLE_ARN \
--role-session-name "TestSession" \
--web-identity-token $ACCESS_TOKEN \
--duration-seconds 3600 \
--query 'Credentials' \
--output json)

AWS_ACCESS_KEY_ID=$(echo $response | jq .AccessKeyId -r)
AWS_SECRET_ACCESS_KEY=$(echo $response | jq .SecretAccessKey -r)
AWS_SESSION_TOKEN=$(echo $response | jq .SessionToken -r)

echo "AccesskeyId: $AWS_ACCESS_KEY_ID"
echo "SessionToken: $AWS_SESSION_TOKEN"

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

aws sts get-caller-identity
