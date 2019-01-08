# PmWiki | Cookbook / Worse (is better)
# https://www.pmwiki.org/wiki/Cookbook/Worse
{% set VERSION = pillar.pmwiki.version -%}
{% set PATH = ["/var/www", VERSION]|join("/") -%}
{% set PATH_UNZIP = [PATH, "staging", "worse"]|join("/") -%}

{% set MD_LIB = "php-markdown-1.8.0" -%}
{% set PATH_MD_LIB = [PATH_UNZIP, MD_LIB]|join("/") -%}


{{ sls }} staging/worse directory:
  file.directory:
    - name: {{ PATH_UNZIP }}
    - mode: '0555'


{{ sls }} extract archive:
  archive.extracted:
    - name: {{ PATH_UNZIP }}
    - source: https://www.pmwiki.org/pmwiki/uploads/Cookbook/worse.zip
    - source_hash: >-
        sha256=05390f44259053cc3fb533fd57d036337c3f6398d13672c02de7cfdf2b0b78e6
    - user: root
    - group: root
    - require:
      - file: pmwiki staging directory
    - unless:
      - test -d {{ PATH_UNZIP }}/cookbook


{{ sls }} update staging/worse permissions:
  file.directory:
    - name: {{ PATH_UNZIP }}
    - dir_mode: '0555'
    - file_mode: '0444'
    - recurse:
      - mode
    - require:
      - archive: {{ sls }} extract archive


{{ sls }} allow markup edit:
  file.replace:
    - name: {{ PATH_UNZIP }}/pub/worse/worse.js
    - pattern: action=edit
    - repl: action=worseedit
    - append_if_not_found: False
    - require:
      - file: {{ sls }} update staging/worse permissions


{{ sls }} symlink into cookbook:
  file.symlink:
    - name: {{ PATH }}/cookbook/worse.php
    - target: ../staging/worse/cookbook/worse.php
    - require:
      - file: pmwiki update cookbook permissions
      - file: {{ sls }} update staging/worse permissions


{{ sls }} symlink into pub:
  file.symlink:
    - name: {{ PATH }}/pub/worse
    - target: ../staging/worse/pub/worse
    - require:
      - file: pmwiki update pub permissions
      - file: {{ sls }} symlink into cookbook
