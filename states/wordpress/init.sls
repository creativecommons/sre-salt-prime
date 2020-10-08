# WARNINGS:
# - Pod "Stage" minions execute composer with dev requirements (no_dev: False)
# - If you updated the user/group within this file, be sure to also update the
#   states/wordpress/files/norm_wp_perms.sh script
#
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set MU_PLUGINS = "{}/mu-plugins".format(WP_CONTENT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set HST = pillar.hst -%}
{% set POD = pillar.pod -%}


include:
  - mysql_cc
  - nodejs
  - php.cli
  - php.curl
  - php.gd
  - php.mysqlnd
  - php.xml
  - php.zip
  - php_cc.composer
  - wordpress.backup
  - wordpress.cli
  - wordpress.domain_mapping
  - wordpress.norm_perms
  - wordpress.queulat
  - wordpress.wordfence


{{ sls }} update webdev group perms cron:
  cron.present:
    - name: '/usr/bin/find /var/www \( -group composer -o -group www-data \) -exec chmod g+w {} + 2>/dev/null'
    - user: root
    - identifier: update_webdev_group_perms
    - special: '@daily'


{{ sls }} docroot:
  file.directory:
    - name: {{ DOCROOT }}
    - mode: '2775'
    - group: webdev
    - require:
      - group: user.webdevs webdev group
{%- if pillar.mounts %}
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}
      - pkg: php_install_curl
      - pkg: php_install_zip
      - user: php_cc.composer user


{{ sls }} wp-config:
  file.managed:
    - name: {{ DOCROOT }}/wp-config.php
    - source:
      - salt://wordpress/files/{{ HST }}-wp-config.php
      - salt://wordpress/files/composer-wp-config.php
    - mode: '0444'
    - template: jinja
    - defaults:
       POD: {{ POD }}
    - require:
      - file: {{ sls }} docroot


{{ sls }} create dir wp:
  file.directory:
    - name: {{ DOCROOT }}/wp
    - mode: '2775'
    - user: composer
    - group: webdev
    - require:
      - file: {{ sls }} docroot
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
    - name: {{ WP_CONTENT }}/{{ dir }}
    - mode: '2775'
    - group: webdev
    - require:
      - file: {{ sls }} dir wp-content
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


{%- set GF_KEY = salt.pillar.get("wordpress:gf_key", false) %}
{%- if GF_KEY %}


{{ sls }} composer .env:
  file.managed:
    - name: {{ DOCROOT }}/.env
    - contents:
      - "# Managed by SaltStack: {{ sls }}"
      - "GRAVITY_FORMS_KEY=\"{{ GF_KEY }}\""
    - group: webdev
    - mode: '0660'
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update
{%- endif %}


{{ sls }} composer.json:
  file.managed:
    - name: {{ DOCROOT }}/composer.json
    - source:
      - salt://wordpress/files/{{ HST }}-composer.json
      - salt://wordpress/files/default-composer.json
    - group: webdev
    - mode: '0664'
    - template: jinja
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
    - group: webdev
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} composer update:
  composer.update:
    - name: {{ DOCROOT }}
    - composer: /usr/local/bin/composer
    - php: /usr/bin/php
    - optimize: True
{%- if POD.startswith("stage") %}
    - no_dev: False
{%- else %}
    - no_dev: True
{%- endif %}
    - user: composer
    - composer_home: /opt/composer
    - require:
      - file: php_cc.composer config.json
      - file: {{ sls }} docroot
    - unless:
      - test -f {{ DOCROOT }}/COMPOSER_SALTSTACK_LOCKED


{{ sls }} composer lock:
  file.managed:
    - name: {{ DOCROOT }}/COMPOSER_SALTSTACK_LOCKED
    - contents:
      - '# This file prevents composer from being run by SaltStack'
    - mode: '0444'
    - user: root
    - group: root
    - require:
      - composer: {{ sls }} composer update


{{ sls }} update dir wp:
  file.directory:
    - name: {{ DOCROOT }}/wp
    - mode: '2775'
    - group: webdev
    - require:
      - composer: {{ sls }} composer update
      - file: {{ sls }} docroot


{{ sls }} symlink wp-content:
  file.symlink:
    - name: {{ DOCROOT }}/wp/wp-content
    - target: ../wp-content
    - force: True
    - backupname: >-
        {{ DOCROOT }}/wp/wp-content.{{ None|strftime("%Y%m%d_%H%M%S") }}
    - user: composer
    - group: webdev
    - require:
      - file: {{ sls }} docroot
    - onlyif:
      - test -d {{ DOCROOT }}/wp/wp-content
