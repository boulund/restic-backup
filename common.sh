#!/bin/bash
# Common functionality for restic-related bash scripts
# Fredrik Boulund 2021

set -eou pipefail

# Path to file containing repo password
password_file="/root/.restic_password"

# Source RESTIC_REPOSITORY, B2_ACCOUNT_ID and B2_ACCOUNT_KEY from secret config file
source /root/.restic_b2account

restic_call="/usr/local/bin/restic --password-file ${password_file}"

