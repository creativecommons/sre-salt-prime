#!/bin/sh
#
# Used together with: minion_upgraded_needed.sh
#
# Based in part on: https://www.shellhacks.com/upgrade-salt-minions/
#
# The official way, documented at the URL below, failed to upgrade a minion
# from 2016.11.2 to 2018.3.3:
# https://docs.saltstack.com/en/latest/faq.html#what-is-the-best-way-to-restart-a-salt-daemon-using-salt
set -o errexit
set -o nounset
TARGET=${1}
exec 0>&- # close stdin
exec 1>&- # close stdout
exec 2>&- # close stderr
salt-call --local pkg.install salt-minion version=${TARGET}
salt-call --local service.restart salt-minion
