include:
  - letsencrypt
  - tls


{{ sls }} debianize letsencrypt archive dirs:
  file.directory:
    - name: /etc/letsencrypt/archive
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'
    - require:
      - pkg: letsencrypt-client
      - pkg: tls installed packages


{{ sls }} debianize letsencrypt live dirs:
  file.directory:
    - name: /etc/letsencrypt/live
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'
    - require:
      - file: {{ sls }} debianize letsencrypt archive dirs


{{ sls }} lencrypt deploy_hook ssl-cert-perms.sh:
  file.managed:
    - name: /etc/letsencrypt/renewal-hooks/deploy/ssl-cert_perms.sh
    - contents:
      - '#!/bin/sh'
      - '/bin/chgrp -R ssl-cert /etc/letsencrypt/live'
      - '/usr/bin/find /etc/letsencrypt/live -type d -exec chmod 2710 {} +'
      - '/usr/bin/find /etc/letsencrypt/live -type f -exec chmod 0640 {} +'
    - mode: '0555'
    - require:
      - pkg: letsencrypt-client
      - pkg: tls installed packages


{% set deploy_hooks = salt["pillar.get"]("letsencrypt:deploy_hooks", False) -%}
{% if deploy_hooks -%}
{% for label, cmd in deploy_hooks.items() -%}
{{ sls }} lencrypt deploy_hook {{ label }}:
  file.managed:
    - name: /etc/letsencrypt/renewal-hooks/deploy/{{ label }}
    - contents:
      - '#!/bin/sh'
      - {{ cmd }}
    - mode: '0555'
    - require:
      - pkg: letsencrypt-client


{% endfor -%}
{% endif -%}
