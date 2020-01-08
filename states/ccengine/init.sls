{%- set SITE_PACKAGES = "/srv/ccengine/env/lib/python2.7/site-packages" %}


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


{%- for dir in ["/srv/ccengine", "/srv/ccengine/env", "/srv/ccengine/src"] %}


{{ sls }} {{ dir }}:
  file.directory:
    - name: {{ dir }}
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}
{%- endfor %}


{{ sls }} creativecommons.org repo:
  git.latest:
    - name: 'https://github.com/creativecommons/creativecommons.org.git'
    - target: /srv/ccengine/src/creativecommons.org
    - rev: {{ pillar.ccengine.branch }}
    - branch: {{ pillar.ccengine.branch }}
    - fetch_tags: False
    - require:
      - file: /srv/ccengine/env
      - file: /srv/ccengine/src
      - pkg: {{ sls }} installed packages


{{ sls }} docroot:
  file.symlink:
    - name: /srv/ccengine/docroot
    - target: /srv/ccengine/src/creativecommons.org/docroot
    - require:
      - git: {{ sls }} creativecommons.org repo


{{ sls }} env setup:
  virtualenv.managed:
    - name: /srv/ccengine/env
    - python: /usr/bin/python
    - system_site_packages: True
    - require:
      - file: {{ sls }} docroot


{%- for repo in ("cc.engine", "cc.i18n", "cc.license", "cc.licenserdf",
                 "rdfadict") %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: /srv/ccengine/src/{{ repo }}
    - rev: {{ pillar.ccengine.branch }}
    - branch: {{ pillar.ccengine.branch }}
    - fetch_tags: False
    - require:
      - virtualenv: {{ sls }} env setup
{%- endfor %}


{{ sls }} rdfadict env install:
  pip.installed:
    - name: rdfadict
    - editable: /srv/ccengine/src/rdfadict
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} rdfadict repo
    - unless:
      - test -f {{ SITE_PACKAGES }}/rdfadict.egg-link


{{ sls }} cc.i18n env install:
  pip.installed:
    - name: cc.i18n
    - editable: /srv/ccengine/src/cc.i18n
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} cc.i18n repo
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.i18n.egg-link


{{ sls }} cc.licenserdf env install:
  pip.installed:
    - name: cc.licenserdf
    - editable: /srv/ccengine/src/cc.licenserdf
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} cc.licenserdf repo
      - pip: {{ sls }} cc.i18n env install
      - pip: {{ sls }} rdfadict env install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.licenserdf.egg-link


{{ sls }} cc.license env install:
  pip.installed:
    - name: cc.license
    - editable: /srv/ccengine/src/cc.license
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} cc.license repo
      - pip: {{ sls }} cc.licenserdf env install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.license.egg-link


{{ sls }} cc.engine env install:
  pip.installed:
    - name: cc.engine
    - editable: /srv/ccengine/src/cc.engine
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} cc.engine repo
      - pip: {{ sls }} cc.i18n env install
      - pip: {{ sls }} cc.license env install
      - pip: {{ sls }} cc.licenserdf env install
    - unless:
      - test -f {{ SITE_PACKAGES }}/cc.engine.egg-link


{{ sls }} Compile Machine Object translation files:
  cmd.run:
    - name: /srv/ccengine/env/bin/compile_mo
    - require:
      - pip: {{ sls }} cc.i18n env install
    - unless:
      - test -d /srv/ccengine/src/cc.i18n/cc/i18n/mo


{{ sls }} Compile translation stats:
  cmd.run:
    - name: /srv/ccengine/env/bin/transstats
    - require:
      - pip: {{ sls }} cc.i18n env install
    - unless:
      - test -f /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv


{{ sls }} Translation stats symlink:
  file.symlink:
    - name: /srv/ccengine/transstats.csv
    - target: /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv
    - require:
      - cmd: {{ sls }} Compile translation stats


{{ sls }} CC Engine config:
  file.managed:
    - name: /srv/ccengine/env/config.ini
    - source: salt://ccengine/files/config.ini
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - cmd: {{ sls }} Compile Machine Object translation files
      - cmd: {{ sls }} Compile translation stats
      - pip: {{ sls }} cc.engine env install
    - watch_in:
      - service: apache2 service


{{ sls }} CC Engine fcgi:
  file.managed:
    - name: /srv/ccengine/env/bin/ccengine.fcgi
    - source: salt://ccengine/files/ccengine.fcgi
    - template: jinja
    - defaults:
        DIR_ENV: /srv/ccengine/env
    - mode: '0555'
    - require:
      - file: {{ sls }} CC Engine config
    - watch_in:
      - service: apache2 service
