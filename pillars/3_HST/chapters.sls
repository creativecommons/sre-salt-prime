include:
  - letsencrypt
  - mysql
  - php


letsencrypt:
  deploy_hooks:
    restart_apache2.sh: service apache2 reload
mounts:
  - spec: /dev/nvme1n1
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
wordpress:
  # Multisite
  multisite: True
  subdomain_install: True
  path_current_site: /
  site_id_current_site: 1
  blog_id_current_site: 1
  sunrise: 'on'
