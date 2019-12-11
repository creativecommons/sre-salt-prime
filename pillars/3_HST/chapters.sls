include:
  - letsencrypt
  - mysql
  - php


letsencrypt:
  post_hooks:
    apache2_reload.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/nvme1n1
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  letsencrypt.cloudflare: {{ sls }}
  mount: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.composer_site: {{ sls }}
wordpress:
  docroot: /var/www/chapters
  # Multisite
  multisite: True
  subdomain_install: True
  path_current_site: /
  site_id_current_site: 1
  blog_id_current_site: 1
  sunrise: 'on'
