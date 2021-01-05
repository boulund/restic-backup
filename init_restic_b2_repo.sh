#!/bin/bash
# Initalize Restic backup repo in Backblaze B2 bucket
# Fredrik Boulund 2021

set -eou pipefail

# Find path to script, to reliably be able to source 'common.sh'
# https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source ${DIR}/common.sh


if ${restic_call} snapshots ; then
  echo "$(date) ERROR: It seems a Restic repo already exists at the requested location."
  exit 1
fi

echo "$(date) OK: No pre-existing Restic repo identified at: ${restic_repo}"
echo "$(date) INFO: Initalizing Restic repo at: ${restic_repo}"
${restic_call} init

