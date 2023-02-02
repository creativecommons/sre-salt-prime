letsencrypt:
  post_hooks:
    restart_nginx.sh: /usr/sbin/service nginx reload
mounts:
  - spec: /dev/xvdf
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
nginx:
  flavor: light
  custom_log_dir: /srv/log-nginx-custom
states:
  mount: {{ sls }}
  nginx.ccstatic: {{ sls }}
