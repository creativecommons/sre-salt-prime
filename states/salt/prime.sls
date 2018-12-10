{% set repo_url = "https://repo.saltstack.com/apt/debian/9/amd64/latest" -%}
{{ sls }} SaltStack Package Repo:
  pkgrepo.managed:
    - name: deb {{ repo_url }}  stretch main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: {{ repo_url }}/SALTSTACK-GPG-KEY.pub
    - clean_file: True
    - require:
        - pkg: common installed packages
    - require_in:
        - pkg: {{ sls }} installed packages

/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - mode: '0444'
    - require:
        - pkgrepo: {{ sls }} SaltStack Package Repo

{{ sls }} installed packages:
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
        - pkg: {{ sls }} installed packages

/etc/salt/master.d/salt-prime.conf:
  file.managed:
    - source: salt://salt/files/salt-prime.conf
    - mode: '0444'
    - follow_symlinks: False
    - watch_in:
        service: service_salt-master
