{% set VERSION = pillar.wikijs.version -%}

{% set WIKI_DIR = "/srv/wikijs-{}".format(VERSION) -%}
{% set CUSTOM_DIR = [WIKI_DIR, "custom"]|join("/") -%}
{% set ARCHIVE_URL = "https://github.com/Requarks/wiki/releases/download" -%}
{% set WIKIJS_DIRS = [".pm2", ".ssh", "data", "logs", "repo"] -%}
{% set NOW = None|strftime("%Y%m%d_%H%M%S") -%}


include:
  - stunnel4.google_ldap


{{ sls }} group:
  group.present:
    - name: wikijs
    - system: True
    - addusers:
{%- for admin in pillar.user.admins.keys() %}
      - {{ admin }}
{%- endfor %}
    - require:
{%- for admin in pillar.user.admins.keys() %}
      - user: user.admins {{ admin }} user
{%- endfor %}


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


{{ sls }} custom directory:
  file.directory:
    - name: {{ CUSTOM_DIR }}
    - mode: '0555'
    - require:
      - archive: {{ sls }} extract build archive


{{ sls }} custom css:
  file.managed:
    - name: {{ CUSTOM_DIR }}/assets-custom.css
    - source: salt://wikijs/files/custom.css
    - mode: '0444'
    - require:
      - file: {{ sls }} custom directory


{{ sls }} custom symlink css:
  file.symlink:
    - name: {{ WIKI_DIR }}/assets/custom.css
    - target: ../custom/assets-custom.css
    - force: True
    - backupname: {{ CUSTOM_DIR }}//assets-custom.css.{{ NOW }}
    - require:
      - file: {{ sls }} custom css


{{ sls }} custom layout.pug:
  file.managed:
    - name: {{ CUSTOM_DIR }}/server-views-layout.pug
    - source: salt://wikijs/files/layout.pug
    - mode: '0444'
    - require:
      - file: {{ sls }} custom directory
      - file: {{ sls }} custom symlink css


{{ sls }} custom symlink layout.pug:
  file.symlink:
    - name: {{ WIKI_DIR }}/server/views/layout.pug
    - target: ../../custom/server-views-layout.pug
    - force: True
    - backupname: {{ CUSTOM_DIR }}/server-views-layout.pug.{{ NOW }}
    - require:
      - file: {{ sls }} custom layout.pug


{{ sls }} custom edit.pug:
  file.managed:
    - name: {{ CUSTOM_DIR }}/server-views-pages-edit.pug
    - source: salt://wikijs/files/edit.pug
    - mode: '0444'
    - require:
      - file: {{ sls }} custom directory


{{ sls }} custom symlink edit.pug:
  file.symlink:
    - name: {{ WIKI_DIR }}/server/views/pages/edit.pug
    - target: ../../../custom/server-views-pages-edit.pug
    - force: True
    - backupname: {{ CUSTOM_DIR }}/server-views-pages-edit.pug.{{ NOW }}
    - require:
      - file: {{ sls }} custom edit.pug


{{ sls }} custom footer.pug:
  file.managed:
    - name: {{ CUSTOM_DIR }}/server-views-common-footer.pug
    - source: salt://wikijs/files/footer.pug
    - mode: '0444'
    - require:
      - file: {{ sls }} custom directory


{{ sls }} custom symlink footer.pug:
  file.symlink:
    - name: {{ WIKI_DIR }}/server/views/common/footer.pug
    - target: ../../../custom/server-views-common-footer.pug
    - force: True
    - backupname: {{ CUSTOM_DIR }}/server-views-common-footer.pug.{{ NOW }}
    - require:
      - file: {{ sls }} custom footer.pug


# https://github.com/Requarks/wiki-v1/issues/52#issuecomment-349194585
{{ sls }} custom user.js:
  file.managed:
    - name: {{ CUSTOM_DIR }}/server-models-user.js
    - source: salt://wikijs/files/user.js
    - mode: '0444'
    - require:
      - file: {{ sls }} custom directory


{{ sls }} custom symlink user.js:
  file.symlink:
    - name: {{ WIKI_DIR }}/server/models/user.js
    - target: ../../custom/server-models-user.js
    - force: True
    - backupname: {{ CUSTOM_DIR }}/server-models-user.js.{{ NOW }}
    - require:
      - file: {{ sls }} custom user.js
    - require_in:
      - file: {{ sls }} config file
    - watch_in:
      - service: {{ sls }} service


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
  git.cloned:
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


{{ sls }} symlink wikijs dir:
  file.symlink:
    - name: /srv/wikijs
    - target: wikijs-{{ VERSION }}
    - force: True
    - backupname: /srv/wikijs.{{ NOW }}
    - require:
      - file: {{ sls }} config file


{{ sls }} install service:
  file.managed:
    - name: /etc/systemd/system/wikijs.service
    - source: salt://wikijs/files/wikijs.service
    - mode: '0444'
    - require:
      - file: {{ sls }} symlink wikijs dir
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
