#!/bin/bash

source .env

# get client_id and client_secret from env variables
client_id=${CLIENT_ID}
client_secret=${CLIENT_SECRET}

# Generate a new client ID and secret if they don't already exist
if [ -z "$client_id" ]; then
    client=$(docker-compose exec hydra \
        hydra create oauth2-client \
        --endpoint http://127.0.0.1:4445/ \
        --audience sts.amazonaws.com \
        --grant-type client_credentials \
        --response-type code,id_token \
        --format json \
        --scope openid)

    client_id=$(echo $client | jq -r '.client_id')
    client_secret=$(echo $client | jq -r '.client_secret')
else
    echo "Using existing Client ID and Secret"
    echo "client id: $client_id"
    echo "client secret: $client_secret"
fi

# Write the environment variables to a file
echo "export ROLE_ARN=\"$ROLE_ARN\"" > .env
echo "export CLIENT_ID=\"$client_id\"" >> .env
echo "export CLIENT_SECRET=\"$client_secret\"" >> .env

# Perform client-credentials action
credentials=$(docker-compose exec hydra \
    hydra perform client-credentials \
    --endpoint http://127.0.0.1:4444/ \
    --audience sts.amazonaws.com \
    --scope openid \
    --format json \
    --client-id "$client_id" \
    --client-secret "$client_secret")

access_token=$(echo $credentials | jq -r '.access_token')
echo "export ACCESS_TOKEN=\"$access_token\"" >> .env
