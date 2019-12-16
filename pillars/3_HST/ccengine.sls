states:
  mount: {{ sls }}
#  nginx.dispatch: {{ sls }}
mounts:
  - spec: /dev/nvme1n1
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
#nginx:
#  flavor: light

