include:
  - letsencrypt
  - mysql
  - php
  - user.webdevs.secrets


letsencrypt:
  post_hooks:
    apache2_reload.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
# Also see pillars/php/init.sls
php:
  apache2:
    ini:
      settings:
        PHP:
          post_max_size: 110M
          upload_max_filesize: 100M
states:
  letsencrypt.cloudflare: {{ sls }}
  mount: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.apache2_tls: {{ sls }}
wordpress:
  docroot: /var/www/chapters
  # Multisite
  multisite: True
  subdomain_install: True
  path_current_site: /
  site_id_current_site: 1
  blog_id_current_site: 1
  sunrise: 'on'
