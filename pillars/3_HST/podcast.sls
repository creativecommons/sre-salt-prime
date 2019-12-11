include:
  - letsencrypt
  - mysql
  - php


letsencrypt:
  post_hooks:
    restart_apache2.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/nvme1n1
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  mount: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.composer_site: {{ sls }}
wordpress:
  docroot: /var/www/podcast
  # Multisite
  multisite: False
