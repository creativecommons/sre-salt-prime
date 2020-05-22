include:
  - php.composer
  - user.webdevs


{{ sls }} user:
  user.present:
    - name: composer
    - gid: {{ pillar.groups.webdev }}
    - home: /opt/composer
    - password: '*'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: user.webdevs webdev group
    - require_in:
      - file: {{ sls }} config.json
      - file: postfix install alias source file aliases


{{ sls }} home:
  file.directory:
    - name: /opt/composer
    - mode: '0775'
    - user: composer
    - group: webdev
    - require:
      - user: {{ sls }} user


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
    - group: webdev
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir cache:
  file.directory:
    - name: /opt/composer/cache
    - mode: '2775'
    - group: webdev
    - require:
      - file: {{ sls }} home
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} dir data:
  file.directory:
    - name: /opt/composer/data
    - mode: '2775'
    - group: webdev
    - require:
      - file: {{ sls }} dir cache
    - require_in:
      - file: {{ sls }} config.json


{{ sls }} config.json:
  file.managed:
    - name: /opt/composer/config.json
    - source: salt://php_cc/files/composer_config.json
    - mode: '0444'
