#!/bin/bash
#
# This helper/wrapper script expects POD (ex. prod, stage) as the first
# argument. Any additional arguments will be added to the end of the salt-call
# command lines (ex. test=True).

set -o errtrace
set -o nounset

#### FUNCTIONS ########################################################

headerone() {
    printf '\e[107m\e[30m'
    printf '### %-75s' "${1}"
    printf '\e[0m\n'
}

run-orch(){
    echo
    headerone "${HST}__${POD}__${LOC} (${ORCH})"
    sudo salt-run state.orchestrate orch.${ORCH} \
        pillar="{'tgt_hst':'${HST}',
                 'tgt_pod':'${POD}',
                 'tgt_loc':'${LOC}'}" \
        saltenv=${USER} \
        ${@}
    echo
}

#### MAIN #############################################################

POD=${1}
shift
LOC='us-east-2'

sudo -v || exit

HST='dispatch'
ORCH='dispatch_host'
run-orch ${@}

HST='ccengine'
ORCH='ccengine_host'
run-orch ${@}

HST='misc'
ORCH='web_host'
run-orch ${@}
