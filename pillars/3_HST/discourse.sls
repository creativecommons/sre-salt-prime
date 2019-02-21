letsencrypt:
  deploy_hooks:
    restart_nginx.sh: service nginx reload
mounts:
  - spec: /dev/nvme1n1
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
