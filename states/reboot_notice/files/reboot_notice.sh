#!/usr/bin/bash
set -o errexit
set -o errtrace
set -o nounset

# shellcheck disable=SC2154
trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

_TODAY="$(/usr/bin/date '+%b %e')"
_LOGS="$(/usr/bin/grep --context=0 "^${_TODAY}.* Out of memory: " \
            /var/log/kern.log)"
# exit ASAP if nothing to report
[[ -z "${_LOGS}" ]] && exit

_LOGS=$'--\n'"${_LOGS}"
_COUNT="$(echo "${_LOGS}" | /usr/bin/grep --count '^--$')"
_HOST="${HOSTNAME%%.*}"
_MINION="$(< /etc/salt/minion_id)"
_MINION="${_MINION%__*}"
_FROM="From: ${USER}+${_HOST}@creativecommons.org"
_SUBJECT="Subject: ${_MINION}: found ${_COUNT} OOM-killer events"
_BODY="${_MINION} kernel log excerpt(s):"$'\n'"${_LOGS}"
printf "To: root\n%s\n%s\n\n%s\n\n." "${_FROM}" "${_SUBJECT}" "${_BODY}" \
    | /usr/lib/sendmail -t
# man sendmail excerpt:
# -t     Extract recipients from message headers. These are added to any re‐
#        cipients specified on the command line.
