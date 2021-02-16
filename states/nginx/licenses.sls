{% import "nginx/jinja2.sls" as nginx with context -%}


include:
  - nginx


{{ sls }} install licenses site:
  file.managed:
    - name: /etc/nginx/sites-available/licenses
    - source: salt://nginx/files/licenses_template
    - mode: '0444'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable licenses site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/licenses
    - target: /etc/nginx/sites-available/licenses
    - require:
      - file: {{ sls }} install licenses site
      - {{ sls }} disable site default
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
