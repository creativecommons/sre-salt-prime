#!/bin/sh
#
# Used together with: upgrade_minion.sh
#
# Based in part on: https://www.shellhacks.com/upgrade-salt-minions/
#
# The official way, documented at the URL below, failed to upgrade a minion
# from 2016.11.2 to 2018.3.3:
# https://docs.saltstack.com/en/latest/faq.html#what-is-the-best-way-to-restart-a-salt-daemon-using-salt
set -o errexit
set -o nounset
TARGET=${1}
if CURRENT="$(dpkg-query -f '${Version}\n' -W salt-minion)"
then
    if [ "${CURRENT}" = "${TARGET}" ]
    then
        # Exit False - Upgrade is not needed (salt-minion is current)
        exit 1
    else
        # Exit True - Upgrade is needed (older salt-minion installed)
        exit 0
    fi
else
    # Exit True - Upgrade is needed (salt-minion not yet installed)
    exit 0
fi
