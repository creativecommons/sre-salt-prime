{% import "apache2/jinja2.sls" as a2 with context -%}

{% set SERVER_NAME = pillar.apache2.server_name -%}
{% set MODS_ENABLE = ["headers", "rewrite"] -%}
{% set SITES_DISABLE = ["000-default.conf", "default-ssl.conf"] -%}


include:
  - apache2
  - apache2.fcgid


{{ sls }} wait for ccengine:
  test.nop:
    - require:
      - test: ccengine completed
    - require_in:
      - pkg: apache2 installed packages


{%- if pillar.ccengine.cc_cache %}


{{ sls }} fcgi cache dir:
  file.directory:
    - name: /srv/ccengine/env/cache
    - group: www-data
    - mode: '2775'
    - require:
      - file: ccengine.env /srv/ccengine/env
      - group: apache2 www-data group
{%- endif %}


{{ sls }} site config:
  file.managed:
    - name: /etc/apache2/sites-available/{{ SERVER_NAME }}.conf
    - source: salt://apache2/files/ccengine.conf
    - template: jinja
    - defaults:
        SERVER_NAME: {{ SERVER_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: apache2 installed packages
      - pkg: apache2.fcgid installed packages
      - file: ccengine.env CC Engine fcgi
    - watch_in:
      - service: apache2 service


{{ sls }} enable site:
  apache_site.enabled:
    - name: {{ SERVER_NAME }}
    - require:
      - file: {{ sls }} site config
    - require_in:
      - apache_site: {{ sls }} disable site 000-default.conf
    - watch_in:
      - service: apache2 service


{{ a2.disable_sites(sls, SITES_DISABLE) }}
{{ a2.enable_mods(sls, MODS_ENABLE) -}}
