{%- set SITE_PACKAGES = "/srv/ccengine/env/lib/python2.7/site-packages" %}


include:
  - ccengine


{{ sls }} /srv/ccengine/env:
  file.directory:
    - name: /srv/ccengine/env
    - require:
      - file: ccengine /srv/ccengine
      - pkg: ccengine installed packages


{{ sls }} env setup:
  virtualenv.managed:
    - name: /srv/ccengine/env
    - python: /usr/bin/python
    - system_site_packages: True
    - require:
      - file: {{ sls }} /srv/ccengine/env


{{ sls }} rdfadict install:
  pip.installed:
    - name: rdfadict
    - editable: /srv/ccengine/src/rdfadict
    - bin_env: /srv/ccengine/env
    - require:
      - git: ccengine.src rdfadict repo
      - virtualenv: {{ sls }} env setup
    - unless:
      - test -f {{ SITE_PACKAGES }}/rdfadict.egg-link


{{ sls }} cc.i18n install:
  pip.installed:
    - name: cc.i18n
    - editable: /srv/ccengine/src/cc.i18n
    - bin_env: /srv/ccengine/env
    - require:
      - git: ccengine.src cc.i18n repo
      - virtualenv: {{ sls }} env setup
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.i18n.egg-link


{{ sls }} cc.licenserdf install:
  pip.installed:
    - name: cc.licenserdf
    - editable: /srv/ccengine/src/cc.licenserdf
    - bin_env: /srv/ccengine/env
    - require:
      - git: ccengine.src cc.licenserdf repo
      - pip: {{ sls }} cc.i18n install
      - pip: {{ sls }} rdfadict install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.licenserdf.egg-link


{{ sls }} cc.license install:
  pip.installed:
    - name: cc.license
    - editable: /srv/ccengine/src/cc.license
    - bin_env: /srv/ccengine/env
    - require:
      - git: ccengine.src cc.license repo
      - pip: {{ sls }} cc.licenserdf install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.license.egg-link


{{ sls }} cc.engine install:
  pip.installed:
    - name: cc.engine
    - editable: /srv/ccengine/src/cc.engine
    - bin_env: /srv/ccengine/env
    - require:
      - git: ccengine.src cc.engine repo
      - pip: {{ sls }} cc.i18n install
      - pip: {{ sls }} cc.license install
      - pip: {{ sls }} cc.licenserdf install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.engine.egg-link


{{ sls }} CC Engine config:
  file.managed:
    - name: /srv/ccengine/env/config.ini
    - source: salt://ccengine/files/config.ini
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - pip: {{ sls }} cc.engine install
    - watch_in:
      - service: apache2 service


{{ sls }} CC Engine fcgi:
  file.managed:
    - name: /srv/ccengine/env/bin/ccengine.fcgi
    - source: salt://ccengine/files/ccengine.fcgi
    - template: jinja
    - defaults:
        DIR_ENV: /srv/ccengine/env
        SLS: {{ sls }}
    - mode: '0555'
    - require:
      - file: {{ sls }} CC Engine config
    - require_in:
      - test: ccengine completed
    - watch_in:
      - service: apache2 service
