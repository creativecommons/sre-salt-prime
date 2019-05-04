{% import "apache2/jinja2.sls" as a2 with context -%}

{% set SERVER_NAME = pillar.wordpress.site -%}
{% set LE_CERT_PATH = ["/etc/letsencrypt/live", SERVER_NAME]|join("/") -%}
{% set SITES_DISABLE = ["000-default.conf", "default-ssl.conf"] -%}


include:
  - apache2
  - apache2.mod_rewrite


{{ sls }} site config:
  file.managed:
    - name: /etc/apache2/sites-available/{{ SERVER_NAME }}.conf
    - source: salt://apache2/files/wordpress_composer.conf
    - template: jinja
    - defaults:
        DOCROOT: {{ pillar.wordpress.docroot }}
        LE_CERT_PATH: {{ LE_CERT_PATH }}
        SERVER_NAME: {{ SERVER_NAME }}
    - require:
      - composer: wordpress.composer_site composer update
      - pkg: apache2 installed packages
      - cron: letsencrypt cron certbot renew
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
