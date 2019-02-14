{% set DOCROOT = pillar.wordpress.docroot -%}
{% set HST = pillar.hst -%}


include:
  - wordpress


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


{{ sls }} file silence.php:
  file.managed:
    - name: {{ DOCROOT }}/silence.php
    - contents:
      - '<?php'
      - '// Silence is golden.'
    - mode: '0444'
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} dir content:
  file.directory:
    - name: {{ DOCROOT }}/content
    - mode: '0555'
    - require:
      - file: {{ sls }} docroot
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} content silence:
  file.symlink:
    - name: {{ DOCROOT }}/content/index.php
    - target: ../silence.php
    - require:
      - file: {{ sls }} file silence.php
      - file: {{ sls }} dir content


{%- for dir in ["languages", "plugins", "themes", "vendor"] %}


{{ sls }} dir content/{{ dir }}:
  file.directory:
    - name: {{ DOCROOT }}/content/{{ dir }}
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} dir content
      - user: php_cc.composer user
    - require_in:
      - composer: {{ sls }} composer update


{{ sls }} content/{{ dir }} silence:
  file.symlink:
    - name: {{ DOCROOT }}/content/{{ dir }}/index.php
    - target: ../../silence.php
    - require:
      - file: {{ sls }} file silence.php
      - file: {{ sls }} dir content/{{ dir }}
{%- endfor %}


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


{{ sls }} dir wp/wp-content:
  file.absent:
    - name: {{ DOCROOT }}/wp/wp-content
    - require:
      - composer: {{ sls }} composer update
