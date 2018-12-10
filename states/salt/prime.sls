{{ sls }} install packages:
  pkg.installed:
    - pkgs:
      - git
      - git-crypt
      - git-doc
      - python-boto
      - python-boto3
      - python3-boto
      - python3-boto3
      - salt-doc
      - salt-master

service_salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - require:
        - pkg: {{ sls }} install packages


/etc/salt/master.d/salt-prime.conf:
  file.managed:
    - source: salt://salt/files/salt-prime.conf
    - mode: '0444'
    - follow_symlinks: False
    - watch_in:
        service: service_salt-master
