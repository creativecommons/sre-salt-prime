{%- set SITE_PACKAGES = "/srv/wiki/env/lib/python2.7/site-packages" %}


include:
  - wiki


{{ sls }} /srv/wiki/env:
  file.directory:
    - name: /srv/wiki/env
    - require:
      - file: wiki /srv/wiki
      - pkg: wiki installed packages


{{ sls }} env setup:
  virtualenv.managed:
    - name: /srv/wiki/env
    - python: /usr/bin/python
    - system_site_packages: True
    - require:
      - file: {{ sls }} /srv/wiki/env


{{ sls }} rdfadict install:
  pip.installed:
    - name: rdfadict
    - editable: /srv/wiki/src/rdfadict
    - bin_env: /srv/wiki/env
    - require:
      - git: wiki.src rdfadict repo
      - virtualenv: {{ sls }} env setup
    - unless:
      - test -f {{ SITE_PACKAGES }}/rdfadict.egg-link


{{ sls }} cc.i18n install:
  pip.installed:
    - name: cc.i18n
    - editable: /srv/wiki/src/cc.i18n
    - bin_env: /srv/wiki/env
    - require:
      - git: wiki.src cc.i18n repo
      - virtualenv: {{ sls }} env setup
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.i18n.egg-link
      - test -d /srv/wiki/src/cc.i18n/cc.i18n.egg-info


{{ sls }} cc.licenserdf install:
  pip.installed:
    - name: cc.licenserdf
    - editable: /srv/wiki/src/cc.licenserdf
    - bin_env: /srv/wiki/env
    - require:
      - git: wiki.src cc.licenserdf repo
      - pip: {{ sls }} cc.i18n install
      - pip: {{ sls }} rdfadict install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.licenserdf.egg-link
      - test -d /srv/wiki/src/cc.licenserdf/cc.licenserdf.egg-info


{{ sls }} cc.license install:
  pip.installed:
    - name: cc.license
    - editable: /srv/wiki/src/cc.license
    - bin_env: /srv/wiki/env
    - require:
      - git: wiki.src cc.license repo
      - pip: {{ sls }} cc.licenserdf install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.license.egg-link
      - test -d /srv/wiki/src/cc.license/cc.license.egg-info


{{ sls }} wiki install:
  pip.installed:
    - name: wiki
    - editable: /srv/wiki/src/wiki
    - bin_env: /srv/wiki/env
    - require:
      - git: wiki.src wiki repo
      - pip: {{ sls }} cc.i18n install
      - pip: {{ sls }} cc.license install
      - pip: {{ sls }} cc.licenserdf install
    - unless:
      - test -f {{ SITE_PACKAGES }}/wiki.egg-link
      - test -d /srv/wiki/src/wiki/wiki.egg-info


{{ sls }} wiki config:
  file.managed:
    - name: /srv/wiki/env/config.ini
    - source: salt://wiki/files/config.ini
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - pip: {{ sls }} wiki install
    - watch_in:
      - service: apache2 service


{{ sls }} wiki fcgi:
  file.managed:
    - name: /srv/wiki/env/bin/wiki.fcgi
    - source: salt://wiki/files/wiki.fcgi
    - template: jinja
    - defaults:
        DIR_ENV: /srv/wiki/env
        SLS: {{ sls }}
    - mode: '0555'
    - require:
      - file: {{ sls }} wiki config
    - require_in:
      - test: wiki completed
    - watch_in:
      - service: apache2 service
