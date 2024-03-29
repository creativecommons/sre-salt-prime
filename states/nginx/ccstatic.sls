{% import "nginx/jinja2.sls" as nginx with context -%}
{% set CERT_NAME = pillar.nginx.cert_name -%}
{% set NOW = None|strftime("%Y%m%d_%H%M%S") -%}


include:
  - nginx
  - nginx.custom_log_formats
  - letsencrypt


{{ sls }} /srv/ccstatic:
  file.directory:
    - name: /srv/ccstatic
    - user: www-data
    - group: www-data
    - dir_mode: '2775'
    - file_mode: '0664'
    - require:
      - pkg: nginx installed packages


{{ sls }} expected location symlink:
  file.symlink:
    - name: /var/www/ccstatic
    - target: /srv/ccstatic
    - require:
      - file: {{ sls }} /srv/ccstatic


{{ sls }} install {{ CERT_NAME }}_basic site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_basic
    - source: salt://nginx/files/basic_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
      - file: nginx.custom_log_formats custom log dir
      - file: nginx.custom_log_formats install conf custom_log_formats
    - watch_in:
      - service: nginx service


{{ sls }} install {{ CERT_NAME }}_tls site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_tls
    - source: salt://nginx/files/ccstatic_tls_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
      - file: nginx.custom_log_formats custom log dir
      - file: nginx.custom_log_formats install conf custom_log_formats
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
      - cron: letsencrypt cron certbot renew
      - file: {{ sls }} install {{ CERT_NAME }}_tls site
      - file: {{ sls }} enable {{ CERT_NAME }}_basic site
      - {{ sls }} disable site default
    - onlyif:
      - test -f /etc/letsencrypt/live/{{ CERT_NAME }}/fullchain.pem
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
