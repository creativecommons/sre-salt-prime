include:
  - mysql
  - php

wiki:
  # set the default here (may be overridden by subsequent sls)
  branch: main
mounts:
  - spec: /dev/xvdf
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  apache2.wiki: {{ sls }}
  mount: {{ sls }}
