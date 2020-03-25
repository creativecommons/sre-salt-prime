linux:
  swapsize: 2
states:
  discourse: {{ sls }}
  mount: {{ sls }}
mounts:
  - spec: /dev/xvdf
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
