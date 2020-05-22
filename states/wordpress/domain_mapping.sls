# Support for WordPress MU Domain Mapping
# http://ottopress.com/2010/wordpress-3-0-multisite-domain-mapping-tutorial/
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set MU_PLUGINS = "{}/mu-plugins".format(WP_CONTENT) -%}


{{ sls }} symlink domain_mapping.php:
  file.symlink:
    - name: {{ MU_PLUGINS }}/domain_mapping.php
    - target: ../plugins/wordpress-mu-domain-mapping/domain_mapping.php
    - user: composer
    - group: webdev
    - require:
      - composer: wordpress composer update
    - onlyif:
      - test -d {{ PLUGINS }}/wordpress-mu-domain-mapping


{{ sls }} symlink sunrise.php:
  file.symlink:
    - name: {{ DOCROOT }}/wp-content/sunrise.php
    - target: plugins/wordpress-mu-domain-mapping/sunrise.php
    - user: composer
    - group: webdev
    - require:
      - file: {{ sls }} symlink domain_mapping.php
    - onlyif:
      - test -d {{ PLUGINS }}/wordpress-mu-domain-mapping
