#!/bin/bash
# This script is designed to be run inside a debian docker container (see rpm-build-docker/Dockerfile) - it assumes that
# the guardian/securedrop-workstation repo is mounted at the location /src in the container

set -e

STAGE=${1}

KEYRING="gu-securedrop-temporary.gpg" # this must correspond to value set in /home/admin/.rpmmacros

gpg --no-default-keyring --keyring $KEYRING  --pinentry loopback --import /tmp/private.asc

# Make rpm config file
cat > /root/.rpmmacros << EOF
%_gpg_name guardian-securedrop-release-$STAGE <digital.investigations@theguardian.com>
%__gpg /usr/bin/gpg
%__gpg_sign_cmd %{__gpg} gpg --force-v3-sigs --verbose --no-armor --pinentry loopback --keyring gu-securedrop-temporary.gpg --no-secmem-warning -u "%{_gpg_name}" -sbo %{__signature_filename} --digest-algo sha256 %{__plaintext_filename}'
EOF

# Locate rpm file
LATEST_RPM_PATH=$(find /src/rpm-build/ -type f -iname '*.rpm' -print0 | sort -zV | head -n 1 )

#Sign RPM
rpm --addsign "$LATEST_RPM_PATH"
