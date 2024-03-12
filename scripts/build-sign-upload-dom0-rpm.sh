#!/usr/bin/env bash
set -e
# This script calls out to the existing build-rpm script then signs the resulting file with the guardian's private key, and uploads it to S3

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
export AWS_PROFILE=investigations
export AWS_DEFAULT_REGION=eu-west-1

STAGE=${1:-"CODE"}

if [[ $STAGE != 'CODE' && $STAGE != 'PROD' ]]; then
  echo "Stage must be CODE or PROD (case sensitive)"
  exit 1
fi

mkdir -p /tmp/sdw


DOCKER_BASE_COMMAND="docker run -v $SCRIPT_PATH/../:/src -v /tmp/sdw:/tmp "
DOCKER_RUN_COMMAND="sdwbuild /bin/sh -c "

# Build docker container
docker build -t sdwbuild $SCRIPT_PATH/../rpm-build-docker

# Generate RPM
$DOCKER_BASE_COMMAND $DOCKER_RUN_COMMAND 'cd /src; scripts/build-rpm.sh'

# Fetch key from secrets manager
SIGNING_KEY_SECRET_ID=$(aws ssm get-parameter --name /$STAGE/investigations/securedrop-workstation/signingKeySecretId | jq -r .Parameter.Value)
aws secretsmanager get-secret-value --region eu-west-1 --secret-id "$SIGNING_KEY_SECRET_ID" | jq .SecretString -r > /tmp/sdw/private.asc

# Sign RPM
echo "Signing RPM..."
$DOCKER_BASE_COMMAND -it $DOCKER_RUN_COMMAND "/src/scripts/sign-rpm.sh $STAGE"

echo "Uploading signed RPM..."
LATEST_RPM_PATH=$(find /$SCRIPT_PATH/../rpm-build/ -type f -iname '*.rpm' | sort -V | tail -n 1 )
LATEST_RPM_FILENAME="$(basename "$LATEST_RPM_PATH")"

# Upload
RELEASE_BUCKET=$(aws ssm get-parameter --name /$STAGE/investigations/securedrop-workstation/releaseBucket | jq -r .Parameter.Value)
aws s3 cp "$LATEST_RPM_PATH" s3://$RELEASE_BUCKET/$LATEST_RPM_FILENAME

# Tidy up temp files
rm /tmp/sdw/private.asc