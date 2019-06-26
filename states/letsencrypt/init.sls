include:
  - tls


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - python-pip


{{ sls }} install certbot:
  pip.installed:
    - name: certbot == {{ pillar.letsencrypt.version }}
    - require:
      - pkg: {{ sls }} installed packages


{%- for dir in ["deploy", "post", "pre"] %}


{{ sls }} config dir {{ dir }}:
  file.directory:
    - name: /etc/letsencrypt/renewal-hooks/{{ dir }}
    - makedirs: True
{%- endfor %}


{{ sls }} cli.ini:
  file.managed:
    - name: /etc/letsencrypt/cli.ini
    - contents:
{%- for key in pillar.letsencrypt.config.keys()|sort() %}
      - '{{ key }} = {{ pillar.letsencrypt.config[key] }}'
{%- endfor %}
    - require:
      - file: {{ sls }} config dir deploy
      - pip: {{ sls }} install certbot


{{ sls }} deploy_hook manage_new_certs.sh:
  file.managed:
    - name: /etc/letsencrypt/renewal-hooks/deploy/manage_new_certs.sh
    - source: salt://letsencrypt/files/manage_new_certs.sh
    - mode: '0555'
    - require:
      - file: {{ sls }} config dir post


{%- set post_hooks = salt["pillar.get"]("letsencrypt:post_hooks", False) %}
{%- if post_hooks %}
{%- for label, cmd in post_hooks.items() %}


{{ sls }} post_hook {{ label }}:
  file.managed:
    - name: /etc/letsencrypt/renewal-hooks/post/{{ label }}
    - contents:
      - '#!/bin/sh'
      - '# Managed by SaltStack'
      - 'set -o errexit'
      - 'set -o nounset'
      - {{ cmd }}
    - mode: '0555'
    - require:
      - file: {{ sls }} config dir post
    - require_in:
      - cron: {{ sls }} cron certbot renew
{%- endfor %}
{%- endif %}


{{ sls }} domainsets:
  file.serialize:
    - name: /etc/letsencrypt/domainsets.yaml
    - formatter: yaml
    - dataset_pillar: letsencrypt:domainsets
    - mode: '0444'
    - require:
      - file: {{ sls }} config dir deploy
      - file: {{ sls }} deploy_hook manage_new_certs.sh


# If the contents of /etc/letsencrypt/domainsets.yaml, then run certbot with
# certonly command and all current domains to ensure the certificate and
# Subject Alternative Name are correct
{%- for domainset in pillar.letsencrypt.domainsets.keys() %}


{{ sls }} certonly install {{ domainset }}:
  cmd.run:
    - name: >-
{%- if pillar.letsencrypt.domainsets[domainset] is none %}
        /usr/local/bin/certbot certonly -d {{ domainset }}
{%- else %}
        /usr/local/bin/certbot certonly -d {{ domainset }} \
{%- for domain in pillar.letsencrypt.domainsets[domainset]|sort() %}
{%- if loop.last %}
          -d {{ domain }}
{%- else %}
          -d {{ domain }} \
{%- endif %}
{%- endfor %}
{%- endif %}
    - onchanges:
      - file: {{ sls }} domainsets
    - require_in:
      - cron: {{ sls }} cron certbot renew
{%- endfor %}


{{ sls }} cron certbot renew:
  cron.present:
    - name: /usr/local/bin/certbot renew
    - identifier: certbot_renew
    - minute: random
    - hour: '0,12'
    - require:
      - file: {{ sls }} cli.ini
      - file: {{ sls }} deploy_hook manage_new_certs.sh