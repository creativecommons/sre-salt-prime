{% set DIR_HOME = "/srv/ccengine/transifex" -%}
{% set DIR_SSH = DIR_HOME + "/.ssh" -%}
{% set SSH_KEY = DIR_SSH + "/" + pillar.transifex.git_ssh_key -%}

include:
  - ccengine
{%- if pillar.ccengine.translations_update %}
  - sudo.transifex
{%- endif %}


{{ sls }} install package:
  pkg.installed:
    - pkgs:
      - transifex-client


{{ sls }} group:
  group.present:
    - name: transifex
    - system: True


{{ sls }} user:
  user.present:
    - name: transifex
    - gid_from_name: True
    - home: {{ DIR_HOME }}
    - password: '!'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: {{ sls }} group
      - file: ccengine /srv/ccengine
      - file: postfix install alias source file aliases


{{ sls }} .transifex config:
  file.managed:
    - name: {{ DIR_HOME }}/.transifexrc
    - source: salt://ccengine/files/transifexrc
    - user: transifex
    - group: transifex
    - mode: '0600'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - user: {{ sls }} user


{{ sls }} git config github.user:
  git.config_set:
    - name: github.user
    - value: {{ pillar.transifex.git_github_user }}
    - user: transifex
    - global: True
    - require:
      - user: {{ sls }} user


{{ sls }} git config user.name:
  git.config_set:
    - name: user.name
    - value: {{ pillar.transifex.git_name }}
    - user: transifex
    - global: True
    - require:
      - git: {{ sls }} git config github.user


{{ sls }} git config user.email:
  git.config_set:
    - name: user.email
    - value: {{ pillar.transifex.git_email }}
    - user: transifex
    - global: True
    - require:
      - git: {{ sls }} git config user.name


{{ sls }} .ssh directory:
  file.directory:
    - name: {{ DIR_SSH }}
    - user: transifex
    - group: transifex
    - mode: '0700'
    - require:
      - user: {{ sls }} user

{{ sls }} ssh public key:
  file.managed:
    - name: {{ SSH_KEY }}.pub
    - source: salt://ccengine/files/{{ pillar.transifex.git_ssh_key }}.pub
    - user: transifex
    - group: transifex
    - mode: '0444'
    - require:
      - file: {{ sls }} .ssh directory


{{ sls }} ssh private key:
  file.managed:
    - name: {{ SSH_KEY }}
    - source: salt://ccengine/files/{{ pillar.transifex.git_ssh_key }}
    - user: transifex
    - group: transifex
    - mode: '0400'
    - require:
      - file: {{ sls }} ssh public key


{{ sls }} ssh config:
  file.managed:
    - name: {{ DIR_SSH }}/config
    - user: transifex
    - group: transifex
    - mode: '0400'
    - contents:
        - '# Manged by SaltStack: {{ sls }}'
        - 'Host github github.com'
        - '    HostName github.com'
        - '    IdentityFile {{ SSH_KEY }}'
        - '    StrictHostKeyChecking no'
        - '    User git'
    - require:
      - file: {{ sls }} ssh private key


{{ sls }} Compile Machine Object translation files:
  cmd.run:
    - name: /srv/ccengine/env/bin/compile_mo
    - runas: transifex
    - require:
      - pip: ccengine.env cc.i18n install
      - user: {{ sls }} user
    - unless:
      - test -d /srv/ccengine/src/cc.i18n/cc/i18n/mo


{{ sls }} Compile translation stats:
  cmd.run:
    - name: /srv/ccengine/env/bin/transstats
    - runas: transifex
    - require:
      - pip: ccengine.env cc.i18n install
      - user: {{ sls }} user
    - unless:
      - test -f /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv


{{ sls }} Translation stats symlink:
  file.symlink:
    - name: /srv/ccengine/transstats.csv
    - target: /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv
    - require:
      - cmd: {{ sls }} Compile translation stats


{%- if pillar.ccengine.translations_update %}


{{ sls }} translations-merge-update.sh cron:
  cron.present:
    - name: /srv/ccengine/src/cc.i18n/scripts/translations-merge-update.sh
    - user: transifex
    - comment: 'Managed by SaltStack: {{ sls }}'
    - identifier: translations-merge-update.sh
    - special: '@hourly'
    - require:
      - file: {{ sls }} .transifex config
      - file: {{ sls }} ssh config
      - file: sudo.transifex add transifex
      - git: {{ sls }} git config user.email
      - pip: ccengine.env cc.i18n install
      - pkg: {{ sls }} install package
      - user: {{ sls }} user
{%- endif %}
