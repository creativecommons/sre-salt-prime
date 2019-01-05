{% set PMWIKI_VER = "pmwiki-2.2.111" -%}
{% set PMWIKI_PATH = ["/var/www/html", PMWIKI_VER]|join("/") -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - libapache2-mod-php


{{ sls }} extract archive:
  archive.extracted:
    - name: /var/www/html
    - source: https://pmwiki.org/pub/pmwiki/{{ PMWIKI_VER }}.tgz
    - source_hash: https://pmwiki.org/pub/pmwiki/{{ PMWIKI_VER }}.md5
    - user: root
    - group: root
    - require:
      - pkg: apache2 installed packages
      - pkg: {{ sls }} installed packages
    - unless:
      - test -d {{ PMWIKI_PATH }}


{{ sls }} pmwiki.php file:
  file.managed:
    - name: {{ PMWIKI_PATH }}/pmwiki.php
    - mode: '0644'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} index.php file:
  file.managed:
    - name: {{ PMWIKI_PATH }}/index.php
    - contents:
      - "<?php include('pmwiki.php');"
    - mode: '0444'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} wiki.d directory:
  file.directory:
    - name: {{ PMWIKI_PATH }}/wiki.d
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} uploads directory:
  file.directory:
    - name: {{ PMWIKI_PATH }}/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} config.php file:
  file.managed:
    - name: {{ PMWIKI_PATH }}/local/config.php
    - source: salt://pmwiki/files/config.php
    - template: jinja
    - mode: '0444'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} symlink pmwiki dir:
  file.symlink:
    - name: /var/www/html/pmwiki
    - target: {{ PMWIKI_VER }}
    - force: True
    - backupname: /var/www/html/pmwiki.PREVIOUS
    - require:
      - archive: {{ sls }} extract archive
