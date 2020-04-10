include:
  - ccengine.docroot
  - ccengine.env
  - ccengine.src
  - ccengine.transifex


{{ sls }} www-data group:
  group.present:
    - name: www-data
    - gid: 33
    - require:
      - pkg: apache2 installed packages


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
      - pipenv
      - python-cssselect
      - python-flup
      - python-librdf
      - python-pip
      - virtualenv


{{ sls }} /srv/ccengine:
  file.directory:
    - name: /srv/ccengine
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} Compile Machine Object translation files:
  cmd.run:
    - name: /srv/ccengine/env/bin/compile_mo
    - require:
      - pip: ccengine.env cc.i18n install
    - unless:
      - test -d /srv/ccengine/src/cc.i18n/cc/i18n/mo


{{ sls }} Compile translation stats:
  cmd.run:
    - name: /srv/ccengine/env/bin/transstats
    - require:
      - pip: ccengine.env cc.i18n install
    - unless:
      - test -f /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv


{{ sls }} Translation stats symlink:
  file.symlink:
    - name: /srv/ccengine/transstats.csv
    - target: /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv
    - require:
      - cmd: {{ sls }} Compile translation stats


{{ sls }} completed:
  test.nop:
    - require:
      - cmd: {{ sls }} Compile Machine Object translation files
      - file: {{ sls }} Translation stats symlink
