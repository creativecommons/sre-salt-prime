#!/bin/bash
#
# On a 3.1 GHz Quad-Core Intel Core i7 MacBook Pro (15-inch, 2017) the
# following settings (8 workers, 4000 users, 160 hatch rate, and 160 second
# run time) results in about 30 seconds of hatching and 2 minutes of testing
# without becoming CPU bound.
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR


ulimit -S -n 8192

echo "# starting locust workers in background"
for x in {1..8}
do
    pipenv run locust --worker --master-host=127.0.0.1 --loglevel ERROR \
        --reset-stats &
done
jobs

echo "# starting locust master in foreground"
if [[ -n "${TESTUSER:-}" ]] && [[ -n "${TESTPASS:-}" ]]
then
    WEBAUTH="--web-auth='${TESTUSER}:${TESTPASS}'"
fi
pipenv run locust --headless --master --master-bind-host=127.0.0.1 \
    --expect-workers=8 --only-summary --reset-stats \
    --users=4000 --spawn-rate=160 --run-time=${RUNTIME:-160s} ${WEBAUTH:-}
