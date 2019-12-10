# - Members of user:webdevs are added to the composer Linux system group
# - Members of user:admins are added to the composer Linux system group
include:
  - php.composer


{{ sls }} group:
  group.present:
    - name: composer
    - system: True
{%- set admins = salt["pillar.get"]("user:admins", False) %}
{%- set webdevs = salt["pillar.get"]("user:webdevs", False) %}
{%- if admins or webdevs %}
    - addusers:
{%- if admins %}
{%- for user in admins.keys() %}
      - {{ user }}
{%- endfor %}
{%- endif %}
{%- if webdevs %}
{%- for user in webdevs.keys() %}
      - {{ user }}
{%- endfor %}
{%- endif %}
{%- endif %}
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


{{ sls }} home:
  file.directory:
    - name: /opt/composer
    - mode: '0775'
    - user: composer
    - group: composer
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
