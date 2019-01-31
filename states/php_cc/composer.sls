include:
  - php.ng.composer


{{ sls }} home:
  file.directory:
    - name: /opt/composer
    - mode: '0555'


{{ sls }} dir archive:
  file.directory:
    - name: /opt/composer/archive
    - mode: '2775'
    - group: www-data
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir cache:
  file.directory:
    - name: /opt/composer/cache
    - mode: '2775'
    - group: www-data
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir data:
  file.directory:
    - name: /opt/composer/data
    - mode: '2775'
    - group: www-data
    - require:
      - file: {{ sls }} dir cache
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} config.json:
  file.managed:
    - name: /opt/composer/config.json
    - source: salt://php_cc/files/composer_config.json
    - mode: '0444'
