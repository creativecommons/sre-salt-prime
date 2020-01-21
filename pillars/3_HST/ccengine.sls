ccengine:
  # set the default here (may be overridden by subsequent sls)
  branch: master
mounts:
  - spec: /dev/nvme1n1
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  apache2.ccengine: {{ sls }}
  ccengine: {{ sls }}
  mount: {{ sls }}