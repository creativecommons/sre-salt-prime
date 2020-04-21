include:
  - ccengine
{%- if pillar.ccengine.translations_update %}
  - sudo.transifex
{%- endif %}


{{ sls }} group:
  group.present:
    - name: transifex
    - system: True


{{ sls }} user:
  user.present:
    - name: transifex
    - gid_from_name: True
    - home: /srv/ccengine
    - createhome: False
    - password: '!'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: {{ sls }} group
      - file: ccengine /srv/ccengine


{{ sls }} config:
  file.managed:
    - name: /srv/ccengine/.transifexrc
    - source: salt://ccengine/files/transifexrc
    - user: transifex
    - group: transifex
    - mode: '0600'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - user: {{ sls }} user


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
      - file: {{ sls }} config
      - file: sudo.transifex add transifex
      - pip: ccengine.env cc.i18n install
      - user: {{ sls }} user
{%- endif %}
