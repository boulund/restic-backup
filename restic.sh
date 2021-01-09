#!/bin/bash
# Run arbitrary Restic commands using preconfigured Backblaze B2 repo
# Fredrik Boulund 2021

set -eou pipefail

# Find path to script, to reliably be able to source 'common.sh'
# https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source ${DIR}/common.sh

if [ "$#" -lt 1 ]; then
  echo "Run arbitrary restic commands; calls restic with preconfigured B2 repo and password"
else
  ${restic_call} "$@"
fi
