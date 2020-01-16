{% import "nginx/jinja2.sls" as nginx with context -%}
{% set CERT_NAME = pillar.nginx.cert_name -%}


include:
  - nginx
  - letsencrypt


{{ sls }} install site {{ CERT_NAME }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}
    - source: salt://nginx/files/dispatch_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable site {{ CERT_NAME }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ CERT_NAME }}
    - target: /etc/nginx/sites-available/{{ CERT_NAME }}
    - require:
      - file: {{ sls }} install site {{ CERT_NAME }}
      - cron: letsencrypt cron certbot renew
    - require_in:
      - {{ sls }} disable site default
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
