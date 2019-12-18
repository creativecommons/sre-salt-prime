{%- set SITE_PACKAGES = "/srv/ccengine/env/lib/python2.7/site-packages" %}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
      - pipenv
      - python-librdf
      - python-pip
      - virtualenv


{%- for dir in ["/srv/ccengine", "/srv/ccengine/env", "/srv/ccengine/src"] %}


{{ sls }} {{ dir }}:
  file.directory:
    - name: {{ dir }}
    - require:
      - mount: mount mount /srv
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


{#- Note: the repo order below is required for successful env
          installations #}
{%- for repo in ["rdfadict", "cc.i18n", "cc.licenserdf", "cc.license",
                 "cc.engine"] %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: /srv/ccengine/src/{{ repo }}
    - rev: {{ pillar.ccengine.branch }}
    - branch: {{ pillar.ccengine.branch }}
    - fetch_tags: False
    - require:
      - virtualenv: {{ sls }} env setup


{{ sls }} {{ repo }} env install:
  pip.installed:
    - name: {{ repo }}
    - editable: /srv/ccengine/src/{{ repo }}
    - bin_env: /srv/ccengine/env
    - require:
      - git: {{ sls }} {{ repo }} repo
    - unless:
      - test -f {{ SITE_PACKAGES }}/{{ repo }}.egg-link
{%- endfor %}


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
    - require:
      - cmd: {{ sls }} Compile Machine Object translation files
      - cmd: {{ sls }} Compile translation stats
      - pip: {{ sls }} cc.engine env install
#    - watch_in:
#      - ...


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
#    - watch_in:
#      - ...
