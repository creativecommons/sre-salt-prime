mounts:
  - spec: /dev/xvdf
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  mount: {{ sls }}
  nginx.ccorg-misc: {{ sls }}
