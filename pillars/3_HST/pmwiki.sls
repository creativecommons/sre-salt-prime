include:
  - stunnel4.secrets


apache2:
  mods:
    enable:
      - rewrite
      - ssl
letsencrypt:
  deploy_hooks:
    restart_apache2.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/nvme1n1
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
pmwiki:
  version: pmwiki-2.2.111
