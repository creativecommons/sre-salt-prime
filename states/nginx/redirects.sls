{% import "nginx/jinja2.sls" as nginx with context -%}
{% set DEFAULT_CERT = pillar.nginx.redirect_default -%}

include:
  - nginx
  - letsencrypt


{{ sls }} install site {{ DEFAULT_CERT }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ DEFAULT_CERT }}
    - source: salt://nginx/files/redirects_default
    - mode: '0444'
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable site {{ DEFAULT_CERT }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ DEFAULT_CERT }}
    - target: /etc/nginx/sites-available/{{ DEFAULT_CERT }}
    - require:
      - file: {{ sls }} install site {{ DEFAULT_CERT }}
      - cron: letsencrypt cron certbot renew
    - require_in:
      - {{ sls }} disable site default
    - watch_in:
      - service: nginx service


{%- for redir in pillar.nginx.redirects %}
{%- set CERT_NAME = redir.crt %}
{%- set SOURCE = redir.src %}
{%- set DESTINATION = redir.dst %}


{{ sls }} install site {{ SOURCE }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ SOURCE }}
    - source: salt://nginx/files/redirects_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SOURCE: {{ SOURCE }}
        DESTINATION: {{ DESTINATION }}
    - require:
      - file: {{ sls }} enable site {{ DEFAULT_CERT }}
    - watch_in:
      - service: nginx service


{{ sls }} enable site {{ SOURCE }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ SOURCE }}
    - target: /etc/nginx/sites-available/{{ SOURCE }}
    - require:
      - file: {{ sls }} install site {{ SOURCE }}
    - watch_in:
      - service: nginx service
{%- endfor %}


{{ nginx.disable_sites(sls, ["default"]) -}}
