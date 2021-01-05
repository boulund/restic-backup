#!/bin/bash
# Mount a Restic repo to inspect backup or restore files. 
# Fredrik Boulund 2021

set -eou pipefail

mountpoint=/mnt/restic

# Find path to script, to reliably be able to source 'common.sh'
# https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source ${DIR}/common.sh

mkdir -pv ${mountpoint}

${restic_call} mount ${mountpoint}

