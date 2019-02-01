include:
  - php.ng.composer


{{ sls }} home:
  file.directory:
    - name: /opt/composer
    - mode: '0555'


{{ sls }} group:
  group.present:
    - name: composer
    - system: True
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json

{{ sls }} user:
  user.present:
    - name: composer
    - home: /opt/composer
    - gid_from_name: True
    - createhome: False
    - password: '*'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: {{ sls }} group
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} www-data group:
  group.present:
    - name: www-data
    - gid: 33
    - addusers:
      - composer
    - require:
      - user: {{ sls }} user


{{ sls }} dir archive:
  file.directory:
    - name: /opt/composer/archive
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir cache:
  file.directory:
    - name: /opt/composer/cache
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir data:
  file.directory:
    - name: /opt/composer/data
    - mode: '2775'
    - group: composer
    - require:
      - file: {{ sls }} dir cache
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} config.json:
  file.managed:
    - name: /opt/composer/config.json
    - source: salt://php_cc/files/composer_config.json
    - mode: '0444'
