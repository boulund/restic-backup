#!/bin/bash
# Common functionality for restic-related bash scripts
# Fredrik Boulund 2021

set -eou pipefail

restic_repo="b2:boulund-monolith-restic:restic"
password_file="/root/.restic_password"

# Source B2_ACCOUNT_ID and B2_ACCOUNT_KEY from secret config file
source /root/.restic_b2account

restic_call="/usr/local/bin/restic --repo ${restic_repo} --password-file ${password_file}"

