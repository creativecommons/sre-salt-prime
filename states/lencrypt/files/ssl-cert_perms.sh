#!/bin/sh
#
# Update Let's Encrypt generated files to be readable by ssl-cert group
#
/bin/chgrp -R ssl-cert /etc/letsencrypt/archive /etc/letsencrypt/live
/usr/bin/find /etc/letsencrypt/archive /etc/letsencrypt/live \
    \( -type d -exec chmod 2710 {} + \) -o \( -type f -exec chmod 0640 {} + \)
