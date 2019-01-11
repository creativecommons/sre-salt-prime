#!/bin/bash
#
# Connectivity testing and troubleshooting - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9190869
#
# Secure LDAP schema - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9188164
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

# Set by SaltStack in {{ slspath }}
LDAP_USER={{ pillar.stunnel4.gsuite_ldap_user }}
LDAP_PASS={{ pillar.stunnel4.gsuite_ldap_pass }}


#### FUNCTIONS ########################################################


error_exit() {
    # Display error message and exit
    local _es _msg
    _msg=${1}
    _es=${2:-1}
    echo "ERROR: ${_msg}" 1>&2
    exit ${_es}
}


headerone() {
    printf '\e[107m\e[30m'
    printf '### %-75s' "${1}"
    printf '\e[0m'
    echo
}


require_sudo() {
    if (( ${UID} != 0 ))
    then
        error_exit 'Must be root (invoke with sudo)'
    fi
    return 0
}


#### MAIN #############################################################

require_sudo

headerone 'Attempt 1 (via stunnel4 with simple auth)'
ldapsearch -x \
    -D "${LDAP_USER}" \
    -w "${LDAP_PASS}" \
    -H ldap://127.0.0.1:1636 \
    -b dc=creativecommons,dc=org \
    '(uid=timid)'
echo
echo

headerone 'Attempt 2 (direct with LDAPTLS envs and SASL auth via cert)'
export LDAPTLS_CERT=/etc/stunnel/Google_2022_01_04_62076.crt
export LDAPTLS_KEY=/etc/stunnel/Google_2022_01_04_62076.key
ldapsearch \
    -H ldaps://ldap.google.com:636 \
    -b dc=creativecommons,dc=org \
    '(uid=timid)'
