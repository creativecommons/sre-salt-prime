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
mkdir -p temp-bootstrap/cache
mkdir -p temp-bootstrap/config
salt-call \
    --config-dir=temp-bootstrap/config \
    --cachedir=temp-bootstrap/cache \
    --local \
    --file-root=. \
    --log-file=temp-bootstrap/salt-call.log \
    --log-level=${LOG_LEVEL:-info} \
    --output-diff \
    --id=bootstrap-aws \
    state.apply core test=${TEST:-True} failhard=True
rm -rf temp-bootstrap
