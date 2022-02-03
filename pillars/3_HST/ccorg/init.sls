include:
  - 3_HST.ccorg.secrets
  - letsencrypt
  - mysql
  - php

letsencrypt:
  post_hooks:
    restart_apache2.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  mount: {{ sls }}
  wordpress.apache2: {{ sls }}
  wordpress.ccorg: {{ sls }}
wordpress:
  multisite: False
  site_conf: creativecommons_org.conf
