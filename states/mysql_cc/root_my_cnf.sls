include:
  - mysql.client


{{ sls }} /root/.my.cnf:
  file.managed:
    - name: /root/.my.cnf
    - contents:
      - '# Managed by SaltStack: {{ sls }}'
{%- for sect in ["client", "msyql", "mysqladmin", "mysqlcheck", "mysqldump"] %}
      - ''
      - '[{{ sect }}]'
      - 'host      = {{ pillar.mysql.server.host }}'
      - 'user      = {{ pillar.mysql.server.root_user }}'
      - 'password  = {{ pillar.mysql.server.root_password }}'
{%- endfor %}
    - mode: '0400'
