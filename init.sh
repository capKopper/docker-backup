#!/bin/bash
set -eo pipefail

_log(){
  declare BLUE="\e[32m" WHITE="\e[39m"
  echo -e "$(date --iso-8601=s)${BLUE} (info)${WHITE}:" $@
}

_error(){
  declare RED="\e[91m" WHITE="\e[39m"
  echo -e "$(date --iso-8601=s)${RED} (error)${WHITE}:" $@
  exit 1
}

do_backup(){
  if [ -n "${BACKUP_DIRS}" -a -n "${BACKUP_TARGET}" ]; then
    _log "Backup in progress..."
    /usr/sbin/backup-manager -v
  else
      _error "BACKUP_DIRS or BACKUP_TARGET isn't defined"
  fi
}

configure_s3cmd(){
  if [ -n "${S3_ACCESS_KEY}" -a -n "${S3_SECRET_KEY}" ]; then
    _log "Configure s3cmd..."
    sed -i -e 's/{{ S3_ACCESS_KEY }}/'$S3_ACCESS_KEY'/g' -e 's/{{ S3_SECRET_KEY }}/'$S3_SECRET_KEY'/g' /etc/s3cmd.conf
  else
    _error "S3_ACCESS_KEY or S3_SECRET_KEY aren't defined"
  fi
}

sync_to_s3(){
  if [ -n "${S3_BUCKET}" -a -n "${S3_TARGET}" ]; then
    _log "Synchronize '${BACKUP_TARGET}' to 's3://${S3_BUCKET}/${S3_TARGET}'..."
    s3cmd --config /etc/s3cmd.conf sync ${BACKUP_TARGET} s3://${S3_BUCKET}/${S3_TARGET}/
  else
    _error "S3_BUCKET or S3_TARGET aren't defined"
  fi
}

main(){
  do_backup
  configure_s3cmd
  sync_to_s3
}


main
