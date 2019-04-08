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
    - source: salt:///lencrypt/files/ssl-cert_perms.sh
    - mode: '0555'
    - require:
      - pkg: letsencrypt-client
      - pkg: tls installed packages


{{ sls }} lencrypt initialize certificates:
  file.managed:
    - name: /usr/local/sbin/le-initialize.sh
    - contents:
      - '#!/bin/sh'
      - '#'
      - '# This is a helper script to assist with mitigating:'
      - '#'
      - '# Adding a new SubjectAlternativeName to a set does not cause a renew'
      - '# - Issue #57 - saltstack-formulas/letsencrypt-formula'
      - '# https://github.com/saltstack-formulas/letsencrypt-formula/issues/57'
      - '#'
      - '/opt/letsencrypt/letsencrypt-auto certonly \'
{%- for domainset in pillar.letsencrypt.domainsets.keys() %}
{%- for domain in pillar.letsencrypt.domainsets[domainset] %}
{%- if loop.last %}
      - '    -d {{ domain }}'
{%- else %}
      - '    -d {{ domain }} \'
{%- endif %}
{%- endfor %}
{%- endfor %}
      - ''
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
