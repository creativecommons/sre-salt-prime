{% import "apache2/jinja2.sls" as a2 with context -%}

{% set SITE_CONF = salt.pillar.get("wordpress:site_conf",
                                   "wordpress_composer.conf") -%}
{% set SERVER_NAME = pillar.wordpress.site -%}
{% set SHELTERED = salt.pillar.get("apache2:sheltered", false) -%}
{% if not SHELTERED -%}
{% set LE_CERT_PATH = ["/etc/letsencrypt/live", SERVER_NAME]|join("/") -%}
{% endif -%}
{% set SITES_DISABLE = ["000-default.conf", "default-ssl.conf"] -%}


include:
{%- if SHELTERED %}
  - apache2
{%- else %}
  - apache2.tls
{%- endif %}
  - apache2.mod_rewrite


{{ sls }} site config:
  file.managed:
    - name: /etc/apache2/sites-available/{{ SERVER_NAME }}.conf
    - source: salt://apache2/files/{{ SITE_CONF }}
    - template: jinja
    - defaults:
        DOCROOT: {{ pillar.wordpress.docroot }}
{%- if not SHELTERED %}
        LE_CERT_PATH: {{ LE_CERT_PATH }}
{%- endif %}
        SERVER_NAME: {{ SERVER_NAME }}
        SHELTERED: {{ SHELTERED }}
    - require:
      - composer: wordpress composer update
      - pkg: apache2 installed packages
{%- if not SHELTERED %}
      - cron: letsencrypt cron certbot renew
{%- endif %}
    - watch_in:
      - service: apache2 service


{{ sls }} enable site:
  apache_site.enabled:
    - name: {{ SERVER_NAME }}
    - require:
      - file: {{ sls }} site config
    - require_in:
      - {{ sls }} disable site 000-default.conf
    - watch_in:
      - service: apache2 service


{{ a2.disable_sites(sls, SITES_DISABLE) }}
