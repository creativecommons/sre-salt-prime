{{ sls }} home:
  file.directory:
    - name: /opt/wp-cli
    - mode: '0555'


{{ sls }} home/bin:
  file.directory:
    - name: /opt/wp-cli/bin
    - mode: '0555'
    - require:
      - file: {{ sls }} home


{% set domain = "https://raw.githubusercontent.com" -%}
{{ sls }} install wp-cli:
  file.managed:
    - name: /opt/wp-cli/bin/wp-cli.phar
    - source: {{ domain }}/wp-cli/builds/gh-pages/phar/wp-cli.phar
    - source_hash: {{ domain }}/wp-cli/builds/gh-pages/phar/wp-cli.phar.sha512
    - mode: '0555'
    - require:
      - file: {{ sls }} home/bin


{{ sls }} add wp-cli to local path:
  file.symlink:
    - name: /usr/local/bin/wp
    - target: /opt/wp-cli/bin/wp-cli.phar
    - force: True
    - require:
      - file: {{ sls }} install wp-cli


# https://wordpress.stackexchange.com/questions/100234/wp-cli-displays-php-notices-when-display-errors-off/145313#145313
{{ sls }} silence PHP file:
  file.managed:
    - name: /opt/wp-cli/silence.php
    - contents:
      - '<?php error_reporting(0); @ini_set("display_errors", 0);'
    - mode: '0444'
    - require:
      - file: {{ sls }} home


{{ sls }} ready:
  test.nop:
    - require:
      - file: {{ sls }} install wp-cli
      - file: {{ sls }} silence PHP file
      - file: {{ sls }} add wp-cli to local path
