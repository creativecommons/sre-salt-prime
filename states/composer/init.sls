include:
  - php_cc


{{ sls }} install composer:
  file.managed:
    - name: /usr/local/bin/composer
    - source: https://github.com/composer/composer/releases/download/1.8.0/composer.phar
    - source_hash: >-
        sha256=0901a84d56f6d6ae8f8b96b0c131d4f51ccaf169d491813d2bcedf2a6e4cefa6
    - mode: '0555'
    - require:
      - pkg: php_install_php
