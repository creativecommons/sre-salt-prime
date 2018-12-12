#!/bin/sh
#
# Based in part on: https://www.shellhacks.com/upgrade-salt-minions/
#
# The official way, documented at the URL below, failed to successfully restart
# a minion
# https://docs.saltstack.com/en/latest/faq.html#what-is-the-best-way-to-restart-a-salt-daemon-using-salt
set -o errexit
set -o nounset
exec 0>&- # close stdin
exec 1>&- # close stdout
exec 2>&- # close stderr
salt-call --local service.restart salt-minion
