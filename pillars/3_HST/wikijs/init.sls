include:
  - 3_HST.wikijs.secrets
  - letsencrypt
  - stunnel4.secrets


letsencrypt:
  post_hooks:
    restart_nginx.sh: /usr/sbin/service nginx reload
mounts:
  - spec: /dev/nvme1n1
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
nginx:
  flavor: light
states:
  letsencrypt: {{ sls }}
  mongodb: {{ sls }}
  mount: {{ sls }}
  nginx.wikijs: {{ sls }}
  nodejs: {{ sls }}
  wikijs: {{ sls }}
wikijs:
  build_hash: >-
    sha256=f114484dd9a9c6aa4daf17e77318a24df2363fd3638439d6f75b57f5baf2a049
  dependencies_hash: >-
    sha256=2c0c5603e8617a08f689284c357e505b6b2c0616af1114e1a74ab6c5652096c8
  version: 1.0.102
