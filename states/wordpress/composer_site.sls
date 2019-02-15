{% set DOCROOT = pillar.wordpress.docroot -%}
{% set HST = pillar.hst -%}


include:
  - wordpress
  - apache2.wordpress_composer


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


{%- for dir in ["languages", "plugins", "themes", "vendor"] %}


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
