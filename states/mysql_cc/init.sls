include:
  - mysql.database
  - mysql.user
  - mysql_cc.debian_integration
  - mysql_cc.root_my_cnf

{{ sls }} installed salt-pip mysqlclient:
  pip.installed:
    - name: mysqlclient
