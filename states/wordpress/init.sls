# WARNINGS:
# - Pod "Stage" minions execute composer with dev requirements (no_dev: False)
# - If you updated the user/group within this file, be sure to also update the
#   states/wordpress/files/norm_wp_perms.sh script
#
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_DIR = "{}/wp".format(DOCROOT) -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set MU_PLUGINS = "{}/mu-plugins".format(WP_CONTENT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set HST = pillar.hst -%}
{% set POD = pillar.pod -%}
{% set SITE = pillar.wordpress.site -%}
{% set TITLE = salt.pillar.get("wordpress:title", false) -%}
{% set ADMIN_USER = salt.pillar.get("wordpress:admin_user", false) -%}
{% set ADMIN_EMAIL = salt.pillar.get("wordpress:admin_email", false) -%}
{% set GF_KEY = salt.pillar.get("wordpress:gf_key", false) -%}
{% set WPCLI = "/usr/local/bin/wp --quiet --no-color --require=/opt/wp-cli/silence.php" -%}
{% set ADMIN_USER = salt.pillar.get("wordpress:admin_user", false) -%}
{% set ADMIN_PASS = salt.pillar.get("wordpress:admin_pass", false) -%}
{% set ADMIN_EMAIL = salt.pillar.get("wordpress:admin_email", false) -%}


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
  - wordpress.git_install
  - wordpress.norm_perms
  - wordpress.pressbooks
  - wordpress.wordfence


{{ sls }} update webdev group perms cron:
  cron.present:
    - name: '/usr/bin/find /var/www \( -group composer -o -group www-data \) -exec chmod g+w {} + 2>/dev/null'
    - user: root
    - identifier: update_webdev_group_perms
    - special: '@daily'


{{ sls }} install packages:
  pkg.installed:
    - pkgs:
      - git


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
      - pkg: {{ sls }} install packages
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
    - name: {{ WP_DIR }}
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
    - name: {{ WP_CONTENT }}/uploads
    - mode: '2775'
    - group: www-data
    - require:
      - file: {{ sls }} dir wp-content
      - group: php_cc.composer www-data group
    - require_in:
      - composer: {{ sls }} composer update


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


{{ sls }} composer saltstack locked:
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


{% if TITLE and ADMIN_USER and ADMIN_EMAIL -%}
{{ sls }} WordPress install:
  cmd.run:
    - name: >-
        {{ WPCLI }} core install --url='{{ SITE }}' --title='{{ TITLE }}'
        --admin_user='{{ ADMIN_USER }}' --admin_email='{{ ADMIN_EMAIL }}'
        --skip-email
    # ' this comment fixes a color syntax highlighting error in vim
    - cwd: {{ WP_DIR }}
    - runas: composer
    - unless:
      - {{ WPCLI }} core is-installed
    - require:
      - file: {{ sls }} composer saltstack locked
      - file: {{ sls }} symlink wp-content
      - file: {{ sls }} update dir wp
      - mysql_grants: mysql_user_{{ pillar.wordpress.db_user }}_%_0
      - test: wordpress.cli ready
    - require_in:
      - test: {{ sls }} ready
{% endif %}


# Initial wordpress setup, it  copies the wpcli script on the destination server and execute it if wordpress is not installed

{{ sls }} create wpcli template:
  file.managed:
    - name: /usr/local/bin/wpcli
    - source: salt://wordpress/files/wpcli
    - mode: '0775'
    - user: root

 
{{ sls }} run wpcli template:
  cmd.run:
    - name: /usr/local/bin/wpcli '{{ WP_DIR }}' '{{ ADMIN_USER }}' '{{ ADMIN_PASS }}' '{{ ADMIN_EMAIL }}'
    - user: root
    - require:
      - file: {{ sls }} install wpcli script
    - unless: /usr/local/bin/wp --path='{{ WP_DIR }}' --no-color --quiet core is-installed ; echo $? 


{{ sls }} ready:
  test.nop:
    - require:
      - file: {{ sls }} composer saltstack locked
      - file: {{ sls }} symlink wp-content
      - file: {{ sls }} update dir wp
      - mysql_grants: mysql_user_{{ pillar.wordpress.db_user }}_%_0
      - test: wordpress.cli ready
