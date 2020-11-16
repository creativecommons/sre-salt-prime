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
  php.mbstring: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.apache2: {{ sls }}
  wordpress.git_install: {{ sls }}
wordpress:
  docroot: /var/www/cert
  # Multisite
  multisite: True
  subdomain_install: True
  path_current_site: /
  site_id_current_site: 1
  blog_id_current_site: 1
  sunrise: 'off'
