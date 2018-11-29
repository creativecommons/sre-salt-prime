#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

unset PYTHONPATH
export AWS_KEY_ID=$(aws configure get aws_access_key_id \
                    --profile creativecommons)
export AWS_ACCESS_KEY=$(aws configure get aws_secret_access_key \
                        --profile creativecommons)

mkdir -p temp-bootstrap/etc/salt
echo "
# Minion
root_dir: ${PWD}/temp-bootstrap/
conf_file: ${PWD}/temp-bootstrap/etc/salt/minion
id: bootstrap-aws
file_roots:
  base:
    - ${PWD}/
state_output_diff: True
file_client: local
failhard: True
" > temp-bootstrap/etc/salt/minion

salt-call \
    --config-dir=${PWD}/temp-bootstrap/etc/salt \
    --log-level=${LOG_LEVEL:-info} \
    state.apply core test=${TEST:-True}
rm -rf temp-bootstrap
