include:
  - mysql
  - php
  - user.webdevs.secrets


apache2:
  sheltered: True
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
  docroot: /var/www/creativecommons
  multisite: False
