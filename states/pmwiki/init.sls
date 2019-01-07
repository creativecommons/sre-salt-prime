{% set TITLE = "Creative Commons PmWiki" -%}
{% set VERSION = pillar.pmwiki.version -%}
{% set PATH = ["/var/www", VERSION]|join("/") -%}

{% set DOMAIN = "pmwiki.creativecommons.org" -%}
{% set PUB_URL = "https://{}/pub".format(DOMAIN) -%}
{% set SCRIPT_URL = "https://{}".format(DOMAIN) -%}


include:
  - .ldap
  - .markdown


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


{% for file in ["pmwiki.php", "README.txt"] -%}
{{ sls }} update {{ file }} permissions:
  file.managed:
    - name: {{ PATH }}/{{ file }}
    - mode: '0444'
    - replace: False
    - require:
      - archive: {{ sls }} extract archive


{% endfor -%}


# Replace .htaccess files
{% for file in ["cookbook/.htaccess", "docs/.htaccess", "local/.htaccess",
                "scripts/.htaccess", "wiki.d/.htaccess"] -%}
{{ sls }} replace {{ file }}:
  file.managed:
    - name: {{ PATH }}/{{ file }}
    - contents:
      - '# VirtualHost uses AllowOverride None'
      - '#  (this file is not read by Apache)'
    - mode: '0444'
    - require:
      - archive: {{ sls }} extract archive


{% endfor -%}


{{ sls }} update cookbook permissions:
  file.directory:
    - name: {{ PATH }}/cookbook
    - mode: '0555'
    - require:
      - archive: {{ sls }} extract archive


{% for dir in ["docs", "local", "pub", "scripts", "wikilib.d"] -%}
{{ sls }} update {{ dir }} permissions:
  file.directory:
    - name: {{ PATH }}/{{ dir }}
    - dir_mode: '0555'
    - file_mode: '0444'
    - recurse:
      - mode
    - require:
      - archive: {{ sls }} extract archive


{% endfor -%}


{{ sls }} staging directory:
  file.directory:
    - name: {{ PATH }}/staging
    - mode: '0555'
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} uploads directory:
  file.directory:
    - name: {{ PATH }}/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} wiki.d directory:
  file.directory:
    - name: {{ PATH }}/wiki.d
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


{{ sls }} download cookbook/pagetoc.php:
  file.managed:
    - name: {{ PATH }}/cookbook/pagetoc.php
    - source: https://www.pmwiki.org/pmwiki/uploads/Cookbook/pagetoc.php
    - source_hash: >-
        sha256=7e5925fa2b825824515c25a4b2deef6ebeac323d3d2fa61837dff77c96a91060
    - mode: '0444'


{{ sls }} config.php file:
  file.managed:
    - name: {{ PATH }}/local/config.php
    - source: salt://pmwiki/files/config.php
    - template: jinja
    - group: www-data
    - mode: '0440'
    - defaults:
        TITLE: {{ TITLE }}
        SCRIPT_URL: {{ SCRIPT_URL }}
        PUB_URL: {{ PUB_URL }}
    - require:
      - file: {{ sls }} cc logo
      - file: {{ sls }} download cookbook/pagetoc.php
      - file: pmwiki.markdown symlink Michelf into cookbook
    - watch_in:
      - service: apache2 service


{{ sls }} symlink pmwiki dir:
  file.symlink:
    - name: /var/www/html
    - target: {{ VERSION }}
    - force: True
    - backupname: /var/www/html.{{ None|strftime("%Y%m%d_%H%M%S") }}
    - require:
      - file: {{ sls }} staging directory
      - file: {{ sls }} uploads directory
      - file: {{ sls }} wiki.d directory
      - file: {{ sls }} config.php file


{{ sls }} install test_google_ldap.sh:
  file.managed:
    - name: /usr/local/sbin/test_google_ldap.sh
    - source: salt://pmwiki/files/test_google_ldap.sh
    - mode: '0555'
