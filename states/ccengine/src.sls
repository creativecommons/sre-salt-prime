include:
  - ccengine


{{ sls }} /srv/ccengine/src:
  file.directory:
    - name: /srv/ccengine/src
    - require:
      - file: ccengine /srv/ccengine


{{ sls }} /srv/ccengine/src/cc.i18n:
  file.directory:
    - name: /srv/ccengine/src/cc.i18n
    - user: transifex
    - group: transifex
    - require:
      - file: {{ sls }} /srv/ccengine/src
      - user: ccengine.transifex user


{%- for repo in ("cc.engine", "cc.i18n", "cc.license", "cc.licenserdf",
                 "creativecommons.org", "rdfadict") %}


{{ sls }} {{ repo }} repo:
  git.latest:
{%- if repo == "cc.i18n" %}
    - name: 'git@github.com:creativecommons/{{ repo }}.git'
{%- else %}
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
{%- endif %}
    - target: /srv/ccengine/src/{{ repo }}
    - rev: {{ pillar.ccengine.branch }}
    - branch: {{ pillar.ccengine.branch }}
{%- if repo == "cc.i18n" %}
    - user: transifex
{%- endif %}
    - fetch_tags: False
    - require:
      - file: {{ sls }} /srv/ccengine/src/cc.i18n
      - pkg: ccengine installed packages
{%- if repo == "cc.i18n" %}
      - file: ccengine.transifex ssh config
      - user: ccengine.transifex user
{%- endif %}
{%- endfor %}


{# Enforce ownership and permissions required for transifex updates #}
{{ sls }} cc.i18n ownership and permissions:
  file.directory:
    - name: /srv/ccengine/src/cc.i18n
    - user: transifex
    - recurse:
      - user
    - require:
      - git: {{ sls }} cc.i18n repo
      - user: ccengine.transifex user
