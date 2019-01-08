# PmWiki | Cookbook / MarkdownMarkupExtension
# https://www.pmwiki.org/wiki/Cookbook/MarkdownMarkupExtension
{% set VERSION = pillar.pmwiki.version -%}
{% set PATH = ["/var/www", VERSION]|join("/") -%}
{% set PATH_UNZIP = [PATH, "staging"]|join("/") -%}

{% set MD_LIB = "php-markdown-1.8.0" -%}
{% set PATH_MD_LIB = [PATH_UNZIP, MD_LIB]|join("/") -%}


{{ sls }} download markdownpmw.php:
  file.managed:
    - name: {{ PATH }}/cookbook/markdownpmw.php
    - source: https://www.pmwiki.org/pmwiki/uploads/Cookbook/markdownpmw.php
    - source_hash: >-
        sha256=e3b9c595f3c552447b14708ac8b8d367e534a742520b53a1cd2ded066d254f75
    - mode: '0444'
    - require:
      - file: pmwiki update cookbook permissions


{{ sls }} extract {{ MD_LIB }} archive:
  archive.extracted:
    - name: {{ PATH_UNZIP }}
    - source: https://github.com/michelf/php-markdown/archive/1.8.0.tar.gz
    - source_hash: >-
        sha256=b7c13d745bc9a7552305c60ac79d59da322d4bd7e4dd85faeb493a9705004551
    - user: root
    - group: root
    - require:
      - file: pmwiki staging directory
    - unless:
      - test -d {{ PATH_MD_LIB }}


{{ sls }} update {{ MD_LIB }} archive permissions:
  file.directory:
    - name: {{ PATH_MD_LIB }}
    - dir_mode: '0555'
    - file_mode: '0444'
    - recurse:
      - mode
    - require:
      - archive: {{ sls }} extract {{ MD_LIB }} archive


{{ sls }} symlink Michelf into cookbook:
  file.symlink:
    - name: {{ PATH }}/cookbook/Michelf
    - target: ../staging/{{ MD_LIB }}/Michelf
    - require:
      - file: {{ sls }} update {{ MD_LIB }} archive permissions
