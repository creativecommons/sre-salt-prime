#!/bin/sh
#
# https://certbot.eff.org/docs/using.html#renewal
#
# RENEWED_LINEAGE: the config livesubdirectory containing the new certificates
#                  and keys (ex. "/etc/letsencrypt/live/example.com")
#
# RENEWED_DOMAINS: a space-delimited list of renewed certificate domains
#                  (ex. "example.com www.example.com")
#
set -o errexit
set -o nounset

# Strip trailing slash and parent directories
PRIMARY=${RENEWED_LINEAGE%/}
PRIMARY=${PRIMARY##*/}

# Create fullchain-privkey.pem bundle
touch ${RENEWED_LINEAGE}/fullchain-privkey.pem
chmod 0640 ${RENEWED_LINEAGE}/fullchain-privkey.pem
cat ${RENEWED_LINEAGE}/fullchain.pem ${RENEWED_LINEAGE}/privkey.pem \
    > ${RENEWED_LINEAGE}/fullchain-privkey.pem

# Update Group and Permissions
/bin/chgrp ssl-cert ${RENEWED_LINEAGE}/*.pem
chmod 0644 ${RENEWED_LINEAGE}/cert.pem
chmod 0644 ${RENEWED_LINEAGE}/chain.pem
chmod 0644 ${RENEWED_LINEAGE}/fullchain.pem
chmod 0640 ${RENEWED_LINEAGE}/privkey.pem

# Install
cp --preserve=all ${RENEWED_LINEAGE}/cert.pem \
    /etc/ssl/certs/${PRIMARY}.pem
cp --preserve=all ${RENEWED_LINEAGE}/chain.pem \
    /etc/ssl/certs/${PRIMARY}_chain.pem
cp --preserve=all ${RENEWED_LINEAGE}/fullchain.pem \
    /etc/ssl/certs/${PRIMARY}_fullchain.pem
cp --preserve=all ${RENEWED_LINEAGE}/privkey.pem \
    /etc/ssl/private/${PRIMARY}.key
cp --preserve=all ${RENEWED_LINEAGE}/fullchain-privkey.pem \
    /etc/ssl/private/${PRIMARY}_fullchain-privkey.pem
