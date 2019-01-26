include:
  - letsencrypt
  - mysql
  - php


letsencrypt:
  deploy_hooks:
    restart_nginx.sh: service apache2 reload
mounts:
  - spec: /dev/nvme1n1
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
