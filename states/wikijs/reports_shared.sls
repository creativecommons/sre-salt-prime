include:
  - virtualenv


{{ sls }} group:
  group.present:
    - name: wikijs
    - system: True


{{ sls }} user:
  user.present:
    - name: wikijs
    - home: /srv/wikijs
    - gid_from_name: True
    - createhome: False
    - password: '*'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: {{ sls }} group


{{ sls }} wikijs directory:
  file.directory:
    - name: /srv/wikijs
    - mode: '0755'
    - owner: wikijs
    - group: wikijs
    - require:
      - user: {{ sls }} user


{{ sls }} wikijs .venvs directory:
  file.directory:
    - name: /srv/wikijs/.venvs
    - mode: '0755'
    - owner: wikijs
    - group: wikijs
    - require:
      - user: {{ sls }} user


{{ sls }} wikijs .ssh directory:
  file.directory:
    - name: /srv/wikijs/.ssh
    - mode: '0700'
    - owner: wikijs
    - group: wikijs
    - require:
      - file: {{ sls }} wikijs directory


{{ sls }} cc-sre-wiki-js-bot ssh public key:
  file.managed:
    - name: /srv/wikijs/.ssh/{{ pillar.wikijs.git_ssh_key }}.pub
    - source: salt://wikijs/files/{{ pillar.wikijs.git_ssh_key }}.pub
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - require:
      - file: {{ sls }} wikijs .ssh directory


{{ sls }} cc-sre-wiki-js-bot ssh private key:
  file.managed:
    - name: /srv/wikijs/.ssh/{{ pillar.wikijs.git_ssh_key }}
    - source: salt://wikijs/files/{{ pillar.wikijs.git_ssh_key }}
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - require:
      - file: {{ sls }} cc-sre-wiki-js-bot ssh public key


{{ sls }} ssh config:
  file.managed:
    - name: /srv/wikijs/.ssh/config
    - contents:
      - '# Managed by SaltStack: {{ sls }}'
      - "\n"
      - 'Host *'
      - '    IdentityFile /srv/wikijs/.ssh/{{ pillar.wikijs.git_ssh_key }}'
    - require:
      - file: {{ sls }} cc-sre-wiki-js-bot ssh private key


{{ sls }} set git user.email:
  git.config_set:
    - name: user.email
    - value: {{ pillar.wikijs.git_server_email }}
    - user: wikijs
    - global: True
    - require:
      - file: {{ sls }} ssh config


{{ sls }} sre-wiki-js repo:
  git.latest:
    - name: {{ pillar.wikijs.git_url }}
    - target: /srv/wikijs/sre-wiki-js
    - user: wikijs
    - fetch_tags: False
    - identity: /srv/wikijs/.ssh/{{ pillar.wikijs.git_ssh_key }}
    - require:
      - git: {{ sls }} set git user.email


{{ sls }} sre-report-to-wikijs repo:
  git.latest:
    - name: 'git@github.com:creativecommons/sre-report-to-wikijs.git'
    - target: /srv/wikijs/sre-report-to-wikijs
    - user: wikijs
    - fetch_tags: False
    - identity: /srv/wikijs/.ssh/{{ pillar.wikijs.git_ssh_key }}
    - require:
      - git: {{ sls }} set git user.email
