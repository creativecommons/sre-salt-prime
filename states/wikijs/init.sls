{% set VERSION = pillar.wikijs.version -%}

{% set WIKI_DIR = "/srv/wikijs-{}".format(VERSION) -%}
{% set ARCHIVE_URL = "https://github.com/Requarks/wiki/releases/download" -%}
{% set WIKIJS_DIRS = [".pm2", ".ssh", "data", "logs", "repo"] -%}


include:
  - stunnel4.google_ldap


{{ sls }} group:
  group.present:
    - name: wikijs
    - system: True
    - addusers:
{%- for admin in pillar.user.admins.keys() %}
      - {{ admin }}
    - require:
      - user: user.admins {{ admin }} user
{% endfor %}


{{ sls }} user:
  user.present:
    - name: wikijs
    - home: /srv/wikijs
    - gid_from_name: True
    - createhome: False
    - password: '*'
    - shell: /usr/sbin/nologin
    - system: True


{{ sls }} {{ WIKI_DIR }} directory:
  file.directory:
    - name: {{ WIKI_DIR }}
    - mode: '0555'


{{ sls }} extract build archive:
  archive.extracted:
    - name: {{ WIKI_DIR }}
    - source: {{ ARCHIVE_URL }}/v{{ VERSION }}/wiki-js.tar.gz
    - source_hash: {{ pillar.wikijs.build_hash }}
    - trim_output: 25
    - enforce_toplevel: False
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory
    - unless:
      - test -d {{ WIKI_DIR }}/assets


{{ sls }} extract dependencies archive:
  archive.extracted:
    - name: {{ WIKI_DIR }}
    - source: {{ ARCHIVE_URL }}/v{{ VERSION }}/node_modules.tar.gz
    - source_hash: {{ pillar.wikijs.dependencies_hash }}
    - trim_output: 25
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory
    - unless:
      - test -d {{ WIKI_DIR }}/node_modules/abab


{{ sls }} update {{ WIKI_DIR }} permissions:
  file.directory:
    - name: {{ WIKI_DIR }}
    - dir_mode: '0555'
    - file_mode: '0444'
    - recurse:
      - mode
    - require:
      - archive: {{ sls }} extract build archive
      - archive: {{ sls }} extract dependencies archive
    - unless:
      - test -f {{ WIKI_DIR }}/config.yml


{% for dir in WIKIJS_DIRS -%}
{{ sls }} {{ WIKI_DIR }}/{{ dir }} directory:
  file.directory:
    - name: {{ WIKI_DIR }}/{{ dir }}
    - user: wikijs
    - group: wikijs
    - mode: '0770'
    - require:
      - user: {{ sls }} user
      - file: {{ sls }} update {{ WIKI_DIR }} permissions
    - require_in:
      - file: {{ sls }} config file


{% endfor -%}


{{ sls }} cc-sre-wiki-js-bot ssh public key:
  file.managed:
    - name: {{ WIKI_DIR }}/{{ pillar.wikijs.git_ssh_key }}.pub
    - source: salt://wikijs/files/{{ pillar.wikijs.git_ssh_key }}.pub
    - group: root
    - mode: '0444'
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory


{{ sls }} cc-sre-wiki-js-bot ssh private key:
  file.managed:
    - name: {{ WIKI_DIR }}/{{ pillar.wikijs.git_ssh_key }}
    - source: salt://wikijs/files/{{ pillar.wikijs.git_ssh_key }}
    - group: wikijs
    - mode: '0440'
    - require:
      - file: {{ sls }} cc-sre-wiki-js-bot ssh public key


{{ sls }} repo:
  git.latest:
    - name: {{ pillar.wikijs.git_url }}
    - target: {{ WIKI_DIR }}/repo
    - user: wikijs
    - identity: /srv/wikijs/{{ pillar.wikijs.git_ssh_key }}
    - require:
      - user: {{ sls }} user
      - file: {{ sls }} cc-sre-wiki-js-bot ssh private key
    - require_in:
      - file: {{ sls }} config file


{{ sls }} config file:
  file.managed:
    - name: {{ WIKI_DIR }}/config.yml
    - source: salt://wikijs/files/config.yml
    - template: jinja
    - group: wikijs
    - mode: '0440'
    # see require_in directives above
    - watch_in:
      - service: {{ sls }} service


{{ sls }} symlink pmwiki dir:
  file.symlink:
    - name: /srv/wikijs
    - target: wikijs-{{ VERSION }}
    - force: True
    - require:
      - file: {{ sls }} config file


{{ sls }} install service:
  file.managed:
    - name: /etc/systemd/system/wikijs.service
    - source: salt://wikijs/files/wikijs.service
    - mode: '0444'
    - require:
      - file: {{ sls }} symlink pmwiki dir
    - watch_in:
      - cmd: {{ sls }} systemd daemon-reload
      - service: {{ sls }} service


{{ sls }} systemd daemon-reload:
  cmd.wait:
    - name: systemctl daemon-reload


{{ sls }} service:
  service.running:
    - name: wikijs
    - enable: True
    - require:
      - {{ sls }} install service
