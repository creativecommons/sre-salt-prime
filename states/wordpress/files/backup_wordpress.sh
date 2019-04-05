#!/bin/bash
#
# Assumptions:
# - DOCROOT/backup is created with desired owern, group, and permissions by
#   system configuration
# - WordPress is installed in DOCROOT/wp
# - The uploads directory is in DOCROOT/wp-content
# - WP CLI is installed at /usr/local/bin/wp
# - /opt/wp-cli/silence.php exists and contains something like:
#       <?php error_reporting(0); @ini_set("display_errors", 0);
#
#
# This script creates the following backups (if invoked with each interval):
#
#   /var/www/SITE/backup
#   ├── daily
#   │   ├── backup_id_2019-04-05-1379620    # (provides timestamp of backup)
#   │   ├── db.sql.gz                       # Compressed database dump
#   │   └── uploads.tgz                     # Tarball of uploads directory
#   ├── now
#   │   ├── backup_id_2019-04-05-a427ee7
#   │   ├── db.sql.gz
#   │   └── uploads.tgz
#   └── weekly
#       ├── backup_id_2019-04-05-04ebe43
#       ├── db.sql.gz
#       └── uploads.tgz
#
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR


#### FUNCTIONS ########################################################


backup_database() {
    # https://developer.wordpress.org/cli/commands/db/export/
    /usr/local/bin/wp --quiet --no-color --require=/opt/wp-cli/silence.php \
        --path="${DOCROOT}/wp" db export --single-transaction - | \
        gzip > ${DESTINATION}/db.sql.gz
}


backup_uploads() {
    tar zcf ${DESTINATION}/uploads.tgz -C ${DOCROOT}/wp-content \
        uploads
}


error_exit() {
    # Display error message and exit
    local _es _msg
    _msg=${1}
    _es=${2:-1}
    echo "ERROR: ${_msg}" 1>&2
    exit ${_es}
}


prep_and_erase_backup_destination() {
    DESTINATION="${DOCROOT}/backup/${INTERVAL}"
    if [[ -d "${DESTINATION}" ]]
    then
        rm -f "${DESTINATION}"/*
    else
        mkdir "${DESTINATION}"
    fi
    local today=$(date -u '+%F')
    local hash=$(date | md5sum)
    local hash=${hash:1:7}
    echo "# ${today}" > ${DESTINATION}/backup_id_${today}-${hash}
}


validate_requirements() {
    command -v /usr/local/bin/wp >/dev/null || \
        error_exit 'the WP CLI is not installed or not in the PATH.'
}


validate_docroot() {
    [[ -n "${DOCROOT}" ]] || \
        error_exit 'the first argument, DOCROOT, is required.'
    [[ -d "${DOCROOT}" ]] || \
        error_exit 'invalid DOCROOT specified. Directory does not exit.'
    [[ -d "${DOCROOT}/backup" ]] || \
        error_exit 'DOCROOT does not contain a backup directory.'
    DOCROOT=${DOCROOT%/}
}


validate_interval() {
    if [[ -z "${INTERVAL}" ]]
    then
       {
           echo 'WARNING: the second argument, INTERVAL, is missing.'
           echo '         The value of "now" will be used.'
           echo -n '         Pausing for 5 seconds'
           for i in {1..5}
           do
               echo -n ' .'
               sleep 1
           done
           echo
       } 1>&2
       INTERVAL=now
    fi
    if [[ "${INTERVAL}" != 'now' ]] && \
       [[ "${INTERVAL}" != 'daily' ]] && \
       [[ "${INTERVAL}" != 'weekly' ]]
    then
        error_exit \
            'invalid INTERVAL specified. Must be "now", "daily", or "weekly".'
    fi
}


#### MAIN #############################################################


DOCROOT=${1:-}
INTERVAL=${2:-}
validate_requirements
validate_docroot
validate_interval
prep_and_erase_backup_destination
backup_database
backup_uploads
