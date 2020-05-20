include:
  - mysql
  - php
  - user.webdevs.secrets


mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
nginx:
  flavor: light
states:
  mount: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.nginx_sheltered: {{ sls }}
wordpress:
  docroot: /var/www/creativecommons
  multisite: False
