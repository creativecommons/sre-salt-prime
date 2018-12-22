{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - awscli
      - git
      - git-crypt
      - git-doc
      - python-boto
      - python-boto3
      - python3-boto
      - python3-boto3
      - salt-master
      - salt-ssh


{{ sls }} service salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} master config file:
  file.managed:
    - name: /etc/salt/master.d/salt_master.conf
    - source: salt://salt/files/salt_master.conf
    - mode: '0444'
    - follow_symlinks: False


{{ sls }} file/pillar roots config file:
  file.managed:
    - name: /etc/salt/master.d/file-pillar_roots.conf
    - source: salt://salt/files/file-pillar_roots.conf
    - mode: '0444'
    - follow_symlinks: False
