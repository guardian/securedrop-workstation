#!/usr/bin/env bash
set -e
# This script calls out to the existing build-rpm script then signs the resulting file with the guardian's private key, and uploads it to S3

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )

$SCRIPT_PATH/build-dom0-rpm

# Fetch key from secrets manager and import into temporary gpg keyring
aws secretsmanager get-secret-value --region eu-west-1 --secret-id "$SIGNING_KEY_SECRET_ID" | jq .SecretString -r > /home/admin/private.asc

KEYRING="gu-securedrop-temporary.gpg" # this must correspond to value set in /home/admin/.rpmmacros
gpg --no-default-keyring  --keyring $KEYRING  --pinentry loopback --import /home/admin/private.asc

# Sign RPM
LATEST_RPM_PATH="$(find $SCRIPT_PATH/../rpm-build/ -type f -iname '*.rpm' -print0 | sort -zV | head -n 1 )"
rpm --addsign "$LATEST_RPM_PATH"

LATEST_RPM_FILENAME="$(basename "$LATEST_RPM_PATH")"

# Upload
aws s3 cp "$LATEST_RPM_PATH" s3://$WORKSTATION_RELEASE_BUCKET/$LATEST_RPM_FILENAME

rm ~/.gnupg/$KEYRING