{% import "nginx/jinja2.sls" as nginx with context -%}


include:
  - nginx
  - letsencrypt


{{ sls }} install site redirects.creativecommons.org:
  file.managed:
    - name: /etc/nginx/sites-available/redirects.creativecommons.org
    - source: salt://nginx/files/redirects_default
    - mode: '0444'
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable site redirects.creativecommons.org:
  file.symlink:
    - name: /etc/nginx/sites-enabled/redirects.creativecommons.org
    - target: /etc/nginx/sites-available/redirects.creativecommons.org
    - require:
      - file: {{ sls }} install site redirects.creativecommons.org
      # from letsencrypt/domains.sls
      - cmd: create-fullchain-privkey-pem-for-redirects.creativecommons.org
    - require_in:
      - {{ sls }} disable site default
    - watch_in:
      - service: nginx service


{%- for redir in pillar.nginx.redirects %}
{%- set CERT_NAME = "redirects.creativecommons.org" %}
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
      - file: {{ sls }} enable site {{ CERT_NAME }}
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
