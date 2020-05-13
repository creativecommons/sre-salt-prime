# Provides support for the felipelavinz/queulat mu-plugin, if it is installed
#
# WARNINGS:
# - If you updated the user/group within this file, be sure to also update the
#   states/wordpress/files/norm_wp_perms.sh script
#
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set MU_PLUGINS = "{}/mu-plugins".format(WP_CONTENT) -%}


{{ sls }} symlink vendor:
  file.symlink:
    - name: {{ DOCROOT }}/vendor
    - target: wp-content/vendor
    - user: composer
    - group: webdev
    - require:
      - composer: wordpress.composer_site composer update
      - group: user.webdevs webdev group
      - pkg: nodejs installed packages
      - user: php_cc.composer user
    - onlyif:
      - test -d {{ MU_PLUGINS }}/queulat


{{ sls }} file wp-content/mu-plugins/queulat.php:
  file.managed:
    - name: {{ MU_PLUGINS }}/queulat.php
    - source: salt://wordpress/files/queulat.php
    - mode: '0664'
    - user: composer
    - group: webdev
    - require:
      - file: {{ sls }} symlink vendor
    - onlyif:
      - test -d {{ MU_PLUGINS }}/queulat


{{ sls }} queulat npm install:
  npm.installed:
    - name: package.json
    - dir: {{ MU_PLUGINS }}/queulat
    - user: composer
    - require:
      - file: {{ sls }} file wp-content/mu-plugins/queulat.php
    - onlyif:
      - test -d {{ MU_PLUGINS }}/queulat
