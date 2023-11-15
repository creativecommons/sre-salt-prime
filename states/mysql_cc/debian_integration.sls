# This state attempts to integrate formula-mysql (combined with
# pillars/mysql/init.sls) in a way that minimizes confusion and surprises.


# Remove MariaDB alternative so that /etc/mysql/my.cnf is absent and can be
# installed as a regular file by formula-mysql. This prevents test run noise
# due to file.managed wanting to update the permissions of # symlinks
{{ sls }} remove my.cnf alternative:
  cmd.run:
    - name: update-alternatives --remove-all my.cnf || true
    - onlyif:
      - test -L /etc/mysql/my.cnf
    - require:
      - file: mysql_config_directory
      - pkg: default-mysql
    - require_in:
      - file: mysql_config


{{ sls }} disable and redirect mariadb.cnf:
  file.symlink:
    - name: /etc/mysql/mariadb.cnf
    - target: my.cnf
    - force: True
    - backupname: /etc/mysql/mariadb.cnf.DISABLED
    - require:
      - file: mysql_config
      - pkg: default-mysql


{{ sls }} my.cnf.fallback:
  file.managed:
    - name: /etc/mysql/my.cnf.fallback
    - source: /etc/mysql/my.cnf
    - user: root
    - group: root
    - mode: '0644'
    - replace: True
    - require:
      - file: mysql_config
      - pkg: default-mysql


# Disable unused configs (unused by settings installed by formula-mysql)
{%- for file in ["conf.d/mysql.cnf", "conf.d/mysqldump.cnf",
                 "mariadb.conf.d/50-client.cnf",
                 "mariadb.conf.d/50-mysql-clients.cnf"] %}


{{ sls }} disable {{ file }}:
  file.rename:
    - name: /etc/mysql/{{ file }}.DISABLED
    - source: /etc/mysql/{{ file }}
    - force: True
    - require:
      - file: mysql_config
      - pkg: default-mysql
{%- endfor %}
