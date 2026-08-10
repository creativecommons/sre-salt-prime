#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

# shellcheck disable=SC2154
trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

_NOW="$(/bin/date '+%s')"
_UPTIME="$(/bin/date --date="$(/usr/bin/uptime --since)" '+%s')"
_UPTIME="$(( _NOW - _UPTIME))"
(( _UPTIME > 86340 )) && exit

_BOOTS="$(/usr/bin/awk '/BOOT_IMAGE/ {print $1" "$2" "$3}' /var/log/syslog \
    | /usr/bin/sort --unique)"
_COUNT="$(echo "${_BOOTS}" | /usr/bin/wc --lines)"
_MINION="$(< /etc/salt/minion_id)"
_MINION="${_MINION%__*}"
_UPTIME="$(/usr/bin/uptime --pretty)"
if (( _COUNT > 0 ))
then
    _SUBJECT="Subject: ${_MINION}: rebooted ${_COUNT} times"
    _BODY="${_UPTIME}"$'\n\n'"${_MINION} boot times:"$'\n'"${_BOOTS}"
else
    _SUBJECT="Subject: ${_MINION}: reboot at least once"
    _BODY="${_UPTIME}"
fi
_HOST="${HOSTNAME%%.*}"
_FROM="From: root+${_HOST}@creativecommons.org"
printf "To: root\n%s\n%s\n\n%s\n\n." "${_FROM}" "${_SUBJECT}" "${_BODY}" \
    | /usr/lib/sendmail -t
# man sendmail excerpt:
# -t     Extract recipients from message headers. These are added to any re‐
#        cipients specified on the command line.
