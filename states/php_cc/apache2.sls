include:
  - apache2.tls
  - php.apache2


{{ sls }} restart apache on php apache2 ini change:
  test.nop:
    - watch:
      - file: php_apache2_ini
    - onchanges:
      - file: php_apache2_ini
    - watch_in:
      - service: apache2 service
