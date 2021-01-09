#!/bin/bash
# Backup script for Monolith using Restic to backup to Backblaze B2
# Fredrik Boulund 2021

set -eou pipefail

logfile="/var/log/restic.log"

# Find path to script, to reliably be able to source 'common.sh'
# https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source ${DIR}/common.sh


echo "$(date) Running Restic backup..." > ${logfile}

${restic_call} backup \
  /home/boulund \
  /etc \
  /root \
  /store \
  --exclude /store/downloads \
  2>&1 | tee --append ${logfile}

echo "$(date) Restic backup completed." >> ${logfile}
