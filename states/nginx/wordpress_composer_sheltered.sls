{% import "nginx/jinja2.sls" as nginx with context -%}
{% set SERVER_NAME = pillar.wordpress.site -%}


include:
  - nginx


{{ sls }} install site {{ SERVER_NAME }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ SERVER_NAME }}
    - source: salt://nginx/files/wordpress_composer_sheltered_template
    - template: jinja
    - defaults:
        DOCROOT: {{ pillar.wordpress.docroot }}
        SERVER_NAME: {{ SERVER_NAME }}
        SLS: {{ sls }}
    - require:
      - composer: wordpress composer update
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable site {{ SERVER_NAME }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ SERVER_NAME }}
    - target: /etc/nginx/sites-available/{{ SERVER_NAME }}
    - require:
      - file: {{ sls }} install site {{ SERVER_NAME }}
    - require_in:
      - {{ sls }} disable site default
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
