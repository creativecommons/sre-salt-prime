{%- set SITE_PACKAGES = "/srv/ccengine/env/lib/python2.7/site-packages" %}


{{ sls }} transifex config:
  file.managed:
    - name: /var/www/.transifexrc
    - source: salt://ccengine/files/transifexrc
    - user: www-data
    - group: www-data
    - mode: '0600'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - group: apache2 www-data group


{{ sls }} transifex-client install:
  pip.installed:
    - name: transifex-client
    - bin_env: /srv/ccengine/env
    - require:
      - file: {{ sls }} transifex config
      - git: ccengine.src rdfadict repo
      - virtualenv: ccengine.env env setup
    - unless:
      - test -f {{ SITE_PACKAGES }}/transifex_client-*.egg-link
