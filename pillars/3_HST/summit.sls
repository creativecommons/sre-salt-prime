include:
  - letsencrypt
  - mysql
  - php
  - user.webdevs.secrets


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
  user.webdevs: {{ sls }}
  wordpress.apache2: {{ sls }}
wordpress:
  docroot: /var/www/summit
  # Multisite
  multisite: False
