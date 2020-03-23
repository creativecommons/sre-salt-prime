#!/bin/bash
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
    headerone ${ORCH}
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
