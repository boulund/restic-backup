#!/bin/bash
# Initalize Restic backup repo in Backblaze B2 bucket
# Fredrik Boulund 2021

set -eou pipefail

restic_repo="b2:boulund-monolith-restic:restic"

password_file="/root/.restic_password"

# Source B2_ACCOUNT_ID and B2_ACCOUNT_KEY from secret config file
source /root/.restic_b2account


restic_call="restic --repo ${restic_repo} --password-file ${password_file}"


if ${restic_call} snapshots ; then
  echo "$(date) ERROR: It seems a Restic repo already exists at the requested location."
  exit 1
fi

echo "$(date) OK: No pre-existing Restic repo identified at: ${restic_repo}"
echo "$(date) INFO: Initalizing Restic repo at: ${restic_repo}"
${restic_call} init

