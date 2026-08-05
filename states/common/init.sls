include:
  - .virtual
  - amazon.cloudwatch_agent


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - dnsutils
      - htop
      - nvme-cli
      - rsync
      - silversearcher-ag
      - time
      - tree

{{ sls }} custom status command:
  file.managed:
    - name: /bin/status
    - user: root
    - group: root
    - mode: '0555'
    - contents:
      - '#!/bin/sh'
      - '# Managed by SaltStack'
      - '/bin/systemctl status --no-pager --full ${@}'
