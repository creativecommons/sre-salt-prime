{% set SSH_KEY = pillar.infra.provisioning.ssh_key.comment -%}


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


{{ sls }} root ssh directory:
  file.directory:
    - name: /root/.ssh
    - mode: '0700'
    - follow_symlinks: False


{{ sls }} root provisioning public ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY }}.pub
    - source: salt://salt/files/{{ SSH_KEY }}.pub
    - mode: '0400'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} root ssh directory


{{ sls }} root provisioning private ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY }}
    - source: salt://salt/files/{{ SSH_KEY }}
    - mode: '0400'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} root ssh directory


{{ sls }} roster.d directory:
  file.directory:
    - name: /etc/salt/roster.d
    - mode: '0755'
    - follow_symlinks: False


{{ sls }} service salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - file: {{ sls }} roster.d directory
      - pkg: {{ sls }} installed packages


{{ sls }} master config file:
  file.managed:
    - name: /etc/salt/master.d/salt_master.conf
    - source: salt://salt/files/salt_master.conf
    - mode: '0444'
    - template: jinja
    - follow_symlinks: False
    - require:
      - file: {{ sls }} roster.d directory
      - file: {{ sls }} root provisioning private ssh key


{{ sls }} file/pillar roots config file:
  file.managed:
    - name: /etc/salt/master.d/file-pillar_roots.conf
    - source: salt://salt/files/file-pillar_roots.conf
    - mode: '0444'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} master config file
