include:
  - mysql
  - php
  #- user.webdevs.secrets


mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  mount: {{ sls }}
  #user.webdevs: {{ sls }}
  #wordpress.composer_site: {{ sls }}
wordpress:
  docroot: /var/www/creativecommons
  # Multisite
  multisite: False
