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

cat << HEREDOC > real_ip_from_cloudflare.conf
# Managed by SaltStack: {{ SLS }}
#
# To update this file, run the updated_cloudlfare_ips.sh script on Salt-Prime
# and then deploy via SaltStack


# Restoring original visitor IPs: Logging visitor IP addresses with
# mod_cloudflare – Cloudflare Support
# https://support.cloudflare.com/hc/en-us/articles/200170786-Restoring-original-visitor-IPs-Logging-visitor-IP-addresses-with-mod-cloudflare-


# https://www.cloudflare.com/ips-v4
$(  for _ip in ${IPV4}
    do
        echo "set_real_ip_from ${_ip};"
    done)


# https://www.cloudflare.com/ips-v6
$(  for _ip in ${IPV6}
    do
        echo "set_real_ip_from ${_ip};"
    done)


real_ip_header X-Forwarded-For;


# vim: ft=nginx:
HEREDOC

# vim: ft=sh:
