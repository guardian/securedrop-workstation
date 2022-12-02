#!/usr/bin/env bash

# This script is designed to make setting up a securedrop-workstation DEV environment easier, by fetching the required config
# files from s3 and putting them in the right place. For production this won't work as we won't want to be storing
# e.g. the sd-journalist private key on S3

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )

export AWS_PROFILE=investigations
export AWS_DEFAULT_REGION=eu-west-1

aws s3 cp s3://securedrop-dev-config/s3auth.conf "$SCRIPT_PATH/../s3auth.conf"
aws s3 cp s3://securedrop-dev-config/config.json "$SCRIPT_PATH/../config.json"
aws s3 cp s3://securedrop-dev-config/sd-journalist.sec "$SCRIPT_PATH/../sd-journalist.sec"

aws secretsmanager get-secret-value  --secret-id securedrop-workstation-repository-public-CODE | jq .SecretString -r > "$SCRIPT_PATH/../guardian-securedrop-release-code.asc"

