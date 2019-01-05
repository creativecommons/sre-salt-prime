{% set VERSION = "pmwiki-2.2.111" -%}
{% set PATH = ["/var/www", VERSION]|join("/") -%}

{% set DOMAIN = "pmwiki.creativecommons.org" -%}
{% set PUB_URL = "https://{}/pub".format(DOMAIN) -%}
{% set SCRIPT_URL = "https://{}".format(DOMAIN) -%}
{% set TITLE = "Creative Commons PmWiki" -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - libapache2-mod-php


{{ sls }} extract archive:
  archive.extracted:
    - name: /var/www
    - source: https://pmwiki.org/pub/pmwiki/{{ VERSION }}.tgz
    - source_hash: https://pmwiki.org/pub/pmwiki/{{ VERSION }}.md5
    - user: root
    - group: root
    - require:
      - pkg: apache2 installed packages
      - pkg: {{ sls }} installed packages
    - unless:
      - test -d {{ PATH }}


{{ sls }} pmwiki.php perms:
  file.managed:
    - name: {{ PATH }}/pmwiki.php
    - mode: '0644'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} wiki.d directory:
  file.directory:
    - name: {{ PATH }}/wiki.d
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} uploads directory:
  file.directory:
    - name: {{ PATH }}/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} cc logo:
  file.managed:
    - name: {{ PATH }}/pub/cc.logo.32.png
    - source: salt://pmwiki/files/cc.logo.32.png
    - mode: '0444'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} config.php file:
  file.managed:
    - name: {{ PATH }}/local/config.php
    - source: salt://pmwiki/files/config.php
    - template: jinja
    - mode: '0444'
    - defaults:
        TITLE: {{ TITLE }}
        SCRIPT_URL: {{ SCRIPT_URL }}
        PUB_URL: {{ PUB_URL }}
    - require:
      - file: {{ sls }} cc logo


{{ sls }} symlink pmwiki dir:
  file.symlink:
    - name: /var/www/html
    - target: {{ VERSION }}
    - force: True
    - backupname: /var/www/html.{{ None|strftime("%Y%m%d_%H%M%S") }}
    - require:
      - file: {{ sls }} pmwiki.php perms
      - file: {{ sls }} wiki.d directory
      - file: {{ sls }} uploads directory
      - file: {{ sls }} config.php file
