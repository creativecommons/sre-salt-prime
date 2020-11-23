# Provides support for the Candela / Pressbooks, if they are installed
#
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set GIT = "/var/www/git" -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set MU_PLUGINS = "{}/mu-plugins".format(WP_CONTENT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set THEMES = "{}/themes".format(WP_CONTENT) -%}


{{ sls }} symlink wp-content/mu-plugins/hm-autoloader.php:
  file.symlink:
    - name: {{ MU_PLUGINS }}/hm-autoloader.php
    - target: {{ PLUGINS }}/pressbooks/hm-autoloader.php
    - require:
      - file: wordpress dir wp-content/mu-plugins
      - composer: wordpress composer update
    - onlyif:
      - test -f {{ PLUGINS }}/pressbooks/hm-autoloader.php


{{ sls }} symlink wp-content/themes/bombadil:
  file.symlink:
    - name: {{ THEMES }}/bombadil
    - target: {{ GIT }}/candela-utility/themes/bombadil
    - require:
      - file: wordpress dir wp-content/themes
    - onlyif:
      - test -d {{ GIT }}/candela-utility/themes/bombadil


{{ sls }} symlink wp-content/themes/candela:
  file.symlink:
    - name: {{ THEMES }}/candela
    - target: {{ GIT }}/candela-utility/themes/candela
    - require:
      - file: wordpress dir wp-content/themes
    - onlyif:
      - test -d {{ GIT }}/candela-utility/themes/candela
