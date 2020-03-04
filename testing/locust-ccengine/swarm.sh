#!/bin/bash
#
# On a 3.1 GHz Quad-Core Intel Core i7 MacBook Pro (15-inch, 2017) the
# following settings (8 slaves, 4000 clients, 160 hatch rate, and 160 second
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

echo "# starting locust slaves in background"
for x in {1..8}
do
    pipenv run locust --slave --master-host=127.0.0.1 --loglevel ERROR \
        --reset-stats &
done
jobs

echo "# starting locust master in foreground"
pipenv run locust --no-web --master --master-bind-host=127.0.0.1 \
    --expect-slaves=8 --only-summary --reset-stats \
    -c4000 -r160 -t160s
