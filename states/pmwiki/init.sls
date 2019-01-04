{% set pmwiki_version = "pmwiki-2.2.111" -%}

{{ sls }} extract archive:
  archive.extracted:
    - name: /var/www
    - source: https://pmwiki.org/pub/pmwiki/{{ pmwiki_version }}.tgz
    - source_hash: https://pmwiki.org/pub/pmwiki/{{ pmwiki_version }}.md5
    - user: root
    - group: root
    - require:
      - pkg: apache2 installed packages


{{ sls }} pmwiki.php file:
  file.managed:
    - name: /var/www/{{ pmwiki_version }}/pmwiki.php
    - mode: '0644'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} wiki.d directory:
  file.directory:
    - name: /var/www/{{ pmwiki_version }}/wiki.d
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} uploads directory:
  file.directory:
    - name: /var/www/{{ pmwiki_version }}/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} config.php file:
  file.managed:
    - name: /var/www/{{ pmwiki_version }}/local/config.php
    - source: salt://pmwiki/files/config.php
    - template: jinja
    - mode: '0444'
    - require:
      - archive: {{ sls }} extract archive
