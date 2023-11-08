{% set SSH_KEY_GITHUB = pillar.infra.github.ssh_key.comment -%}
{% set SSH_KEY_PROV = pillar.infra.provisioning.ssh_key.comment -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - awscli
      - colordiff
      - git
      - git-crypt
      - git-doc
      - ipv6calc
      - python3-boto
      - python3-boto3
      - python3-git
      - salt-master
      - salt-ssh


{{ sls }} installed salt-pip boto:
  pip.installed:
    - name: boto


{{ sls }} installed salt-pip boto3:
  pip.installed:
    - name: boto3


{{ sls }} root ssh directory:
  file.directory:
    - name: /root/.ssh
    - mode: '0700'
    - follow_symlinks: False


{{ sls }} add GitHub ssh known host entry:
  ssh_known_hosts.present:
    - name: github.com
    - user: root


{{ sls }} root GitHub read-only public ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY_GITHUB }}.pub
    - source: salt://salt/files/{{ SSH_KEY_GITHUB }}.pub
    - mode: '0400'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} root ssh directory


{{ sls }} root GitHub read-only private ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY_GITHUB }}
    - source: salt://salt/files/{{ SSH_KEY_GITHUB }}
    - mode: '0400'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} root ssh directory


{{ sls }} root provisioning public ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY_PROV }}.pub
    - source: salt://salt/files/{{ SSH_KEY_PROV }}.pub
    - mode: '0400'
    - follow_symlinks: False
    - require:
      - file: {{ sls }} root ssh directory


{{ sls }} root provisioning private ssh key:
  file.managed:
    - name: /root/.ssh/{{ SSH_KEY_PROV }}
    - source: salt://salt/files/{{ SSH_KEY_PROV }}
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
      - pip: {{ sls }} installed salt-pip boto
      - pip: {{ sls }} installed salt-pip boto3
      - pkg: {{ sls }} installed packages


{{ sls }} master config file:
  file.managed:
    - name: /etc/salt/master.d/salt_master.conf
    - source: salt://salt/files/salt_master.conf
    - mode: '0444'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - follow_symlinks: False
    - require:
      - file: {{ sls }} roster.d directory
      - file: {{ sls }} root provisioning private ssh key


{{ sls }} file/pillar roots config file:
  file.managed:
    - name: /etc/salt/master.d/file-pillar_roots.conf
    - source: salt://salt/files/file-pillar_roots.conf
    - mode: '0444'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - follow_symlinks: False
    - require:
      - file: {{ sls }} master config file

{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}
{% set users = admins -%}

{{ sls }} salt group:
  group.present:
    - name: salt
    - gid: 118
{%- if users %}
    - addusers:
{%- for username in users|sort %}
        - {{ username }}
{%- endfor %}
{%- endif %}
    - require:
      - pkg: {{ sls }} installed packages
{%- if admins %}
{%- for username in admins %}
      - user: user.admins {{ username }} user
{%- endfor %}
{%- endif %}
