{% set DOCROOT = pillar.wordpress.docroot -%}
{% set HST = pillar.hst -%}


include:
  - wordpress
  - apache2.wordpress_composer


{{ sls }} update webdev group perms cron:
  cron.present:
    - name: '/usr/bin/find /var/www \( -group composer -o -group www-data \) -exec chmod g+w {} +'
    - user: root
    - identifier: update_webdev_group_perms
    - special: '@daily'


{{ sls }} docroot:
  file.directory:
    - name: {{ DOCROOT }}
    - mode: '0555'
    - require:
      - mount: mount mount /var/www


{{ sls }} wp-config:
  file.managed:
    - name: {{ DOCROOT }}/wp-config.php
    - source:
      - salt://wordpress/files/{{ HST }}-wp-config.php
      - salt://wordpress/files/composer-wp-config.php
    - mode: '0444'
    - template: jinja
    - require:
      - file: {{ sls }} docroot


{{ sls }} dir wp:
  file.directory:
    - name: {{ DOCROOT }}/wp
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} docroot
      - user: php_cc.composer user
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} dir wp-content:
  file.directory:
    - name: {{ DOCROOT }}/wp-content
    - mode: '0555'
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update


{%- for dir in ["languages", "mu-plugins", "plugins", "themes", "upgrade",
                "vendor"] %}


{{ sls }} dir wp-content/{{ dir }}:
  file.directory:
    - name: {{ DOCROOT }}/wp-content/{{ dir }}
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} dir wp-content
      - user: php_cc.composer user
    - require_in:
      - composer: {{ sls }} composer update
{%- endfor %}


{{ sls }} dir wp-content/uploads:
  file.directory:
    - name: {{ DOCROOT }}/wp-content/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - file: {{ sls }} dir wp-content
      - group: php_cc.composer www-data group
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} composer.json:
  file.managed:
    - name: {{ DOCROOT }}/composer.json
    - source:
      - salt://wordpress/files/{{ HST }}-composer.json
      - salt://wordpress/files/default-composer.json
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} composer.lock:
  file.managed:
    - name: {{ DOCROOT }}/composer.lock
    - contents:
      - '{}'
    - replace: False
    - mode: '0664'
    - group: composer
    - require:
      - file: {{ sls }} docroot
      - user: php_cc.composer user
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} composer update:
  composer.update:
    - name: {{ DOCROOT }}
    - composer: /usr/local/bin/composer
    - php: /usr/bin/php
    - optimize: True
    - no_dev: True
    - user: composer
    - composer_home: /opt/composer
    - require:
      - php_cc.composer config.json
    - unless:
      - test -f {{ DOCROOT }}/COMPOSER_SALTSTACK_LOCKED


{{ sls }} composer lock:
  file.managed:
    - name: {{ DOCROOT }}/COMPOSER_SALTSTACK_LOCKED
    - contents:
      - '# This file prevents composer from being run by SaltStack'
    - mode: '0444'
    - require:
      - composer: {{ sls }} composer update


{{ sls }} symlink wp-content:
  file.symlink:
    - name: {{ DOCROOT }}/wp/wp-content
    - target: ../wp-content
    - force: True
    - backupname: >-
        {{ DOCROOT }}/wp/wp-content.{{ None|strftime("%Y%m%d_%H%M%S") }}
    - onlyif:
      - test -d {{ DOCROOT }}/wp/wp-content


# Support for Wordfence 1/2
{{ sls }} dir wp-content/plugins/wordfence:
  file.directory:
    - name: {{ DOCROOT }}/wp-content/plugins/wordfence
    - mode: '2775'
    - group: www-data
    - require:
      - composer: {{ sls }} composer update
      - group: php_cc.composer www-data group
    - onlyif:
      - test -d {{ DOCROOT }}/wp-content/plugins/wordfence


# Support for Wordfence 2/2
{{ sls }} dir wp-content/wflogs:
  file.directory:
    - name: {{ DOCROOT }}/wp-content/wflogs
    - mode: '2775'
    - group: www-data
    - require:
      - composer: {{ sls }} composer update
      - group: php_cc.composer www-data group
    - onlyif:
      - test -d {{ DOCROOT }}/wp-content/plugins/wordfence


# Support for WordPress MU Domain Mapping 1/2
# http://ottopress.com/2010/wordpress-3-0-multisite-domain-mapping-tutorial/
{{ sls }} file domain_mapping.php:
  file.symlink:
    - name: {{ DOCROOT }}/wp-content/mu-plugins/domain_mapping.php
    - target: ../plugins/wordpress-mu-domain-mapping/domain_mapping.php
    - require:
      - composer: {{ sls }} composer update
    - onlyif:
      - test -d {{ DOCROOT }}/wp-content/plugins/wordpress-mu-domain-mapping


# Support for WordPress MU Domain Mapping 2/2
# http://ottopress.com/2010/wordpress-3-0-multisite-domain-mapping-tutorial/
{{ sls }} file sunrise.php:
  file.symlink:
    - name: {{ DOCROOT }}/wp-content/sunrise.php
    - target: plugins/wordpress-mu-domain-mapping/sunrise.php
    - require:
      - composer: {{ sls }} composer update
    - onlyif:
      - test -d {{ DOCROOT }}/wp-content/plugins/wordpress-mu-domain-mapping
