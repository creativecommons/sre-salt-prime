{% import "nginx/jinja2.sls" as nginx with context -%}
{% set CERT_NAME = pillar.nginx.cert_name -%}


include:
  - nginx
  - letsencrypt


{{ sls }} install {{ CERT_NAME }}_basic site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_basic
    - source: salt://nginx/files/cclicdev_basic_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{%- if pillar.pod.startswith("stage") %}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2-utils
    - require:
      - pkg: nginx installed packages


{{ sls }} basic authentication user file:
  file.managed:
    - name: /etc/nginx/htpasswd
    - source: ~
    - group: www-data
    - mode: '0440'
    - replace: False
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} basic authentication user exists:
  webutil.user_exists:
    - name: {{ pillar.nginx.auth_basic_user }}
    - password: {{ pillar.nginx.auth_basic_pass }}
    - htpasswd_file: /etc/nginx/htpasswd
    - options: s
    - update: True
    - require:
      - file: {{ sls }} basic authentication user file
{%- endif %}


{{ sls }} install {{ CERT_NAME }}_tls site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_tls
    - source: salt://nginx/files/cclicdev_tls_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
{%- if pillar.pod.startswith("stage") %}
      - webutil: {{ sls }} basic authentication user exists
{%- endif %}
    - watch_in:
      - service: nginx service


{{ sls }} enable {{ CERT_NAME }}_basic site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ CERT_NAME }}_basic
    - target: /etc/nginx/sites-available/{{ CERT_NAME }}_basic
    - require:
      - file: {{ sls }} install {{ CERT_NAME }}_basic site
      - {{ sls }} disable site default
    - require_in:
      - pip: letsencrypt install certbot
    - watch_in:
      - service: nginx service


{{ sls }} enable {{ CERT_NAME }}_tls site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ CERT_NAME }}_tls
    - target: /etc/nginx/sites-available/{{ CERT_NAME }}_tls
    - require:
      - cmd: django.cclicdev execute run_gunicorn.sh
      - cron: letsencrypt cron certbot renew
      - file: {{ sls }} install {{ CERT_NAME }}_tls site
      - file: {{ sls }} enable {{ CERT_NAME }}_basic site
      - {{ sls }} disable site default
    - onlyif:
      - test -f /etc/letsencrypt/live/{{ CERT_NAME }}/fullchain.pem
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
