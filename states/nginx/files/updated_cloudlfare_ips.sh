#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

IPV4="$(curl --http2 --raw --silent https://www.cloudflare.com/ips-v4 \
         | sort -V)"
IPV6="$(curl --http2 --raw --silent https://www.cloudflare.com/ips-v6 \
        | ipv6calc --addr_to_fulluncompressed \
        | sort \
        | ipv6calc --addr_to_compressed)"

{
    echo '# Managed by SaltStack: {{ SLS }}'
    echo '#'
    printf '# To update this file, run the updated_cloudlfare_ips.sh script'
    printf ' on Salt-Prime\n# and then deploy via SaltStack\n'
    echo
    echo
    echo '# Restoring original visitor IPs: Logging visitor IP addresses with'
    echo '# mod_cloudflare – Cloudflare Support'
    printf '# https://support.cloudflare.com/hc/en-us/articles/'
    printf '200170786-Restoring-original-visitor-IPs-Logging-visitor-IP-'
    printf 'addresses-with-mod-cloudflare-\n'
    echo
    echo
    echo '# https://www.cloudflare.com/ips-v4'
    for _ip in ${IPV4}
    do
        echo "set_real_ip_from ${_ip};"
    done
    echo
    echo
    echo '# https://www.cloudflare.com/ips-v6'
    for _ip in ${IPV6}
    do
        echo "set_real_ip_from ${_ip};"
    done
    echo
    echo
    echo 'real_ip_header X-Forwarded-For;'
    echo
    echo
    echo '# vim: ft=nginx:'
} > real_ip_from_cloudflare.conf

# vim: ft=sh:
