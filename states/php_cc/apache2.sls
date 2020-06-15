include:
{%- if salt.pillar.get("apache2:sheltered", false) %}
  - apache2
{%- else %}
  - apache2.tls
{%- endif %}
  - php.apache2


{{ sls }} restart apache on php apache2 ini change:
  test.nop:
    - watch:
      - file: php_apache2_ini
    - onchanges:
      - file: php_apache2_ini
    - watch_in:
      - service: apache2 service
