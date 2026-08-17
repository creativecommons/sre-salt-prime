#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR


DIR_REPO="$(cd -P -- "${0%/*}/.." && pwd -P)"
HEADER="# Managed by SaltStack: {{ SLS }}
#
# To update this file, run ./bin/update_cloudlfare_ips.sh script on Salt-Prime
# and then deploy via SaltStack


# Restoring original visitor IPs · Cloudflare Support docs
# https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/restoring-original-visitor-ips/"
IPV4="$(curl --http2 --raw --silent https://www.cloudflare.com/ips-v4 \
         | sort -V)"
IPV6="$(curl --http2 --raw --silent https://www.cloudflare.com/ips-v6 \
        | ipv6calc --addr_to_fulluncompressed \
        | sort \
        | ipv6calc --addr_to_compressed)"

# Apache2
cd "${DIR_REPO}/states/apache2/files"
cat << HEREDOC > remoteip.conf
${HEADER}


# https://httpd.apache.org/docs/current/mod/mod_log_config.html#formats
LogFormat "%{%F %T}t %a %u %>s \"%r\" \"%{Location}o\" %O \"%{Referer}i\" \"%{User-Agent}i\"" remoteipcustom
RemoteIPHeader CF-Connecting-IP


# https://www.cloudflare.com/ips-v4
$(  for _ip in ${IPV4}
    do
        echo "RemoteIPTrustedProxy ${_ip}"
    done)


# https://www.cloudflare.com/ips-v6
$(  for _ip in ${IPV6}
    do
        echo "RemoteIPTrustedProxy ${_ip}"
    done)


# vim: ft=apache:
HEREDOC

# NGINX
cd "${DIR_REPO}/states/nginx/files"
cat << HEREDOC > real_ip_from_cloudflare.conf
${HEADER}


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
