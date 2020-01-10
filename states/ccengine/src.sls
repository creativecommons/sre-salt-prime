include:
  - ccengine


{{ sls }} /srv/ccengine/src:
  file.directory:
    - name: /srv/ccengine/src
    - require:
      - file: ccengine /srv/ccengine


{%- for repo in ("cc.engine", "cc.i18n", "cc.license", "cc.licenserdf",
                 "creativecommons.org", "rdfadict") %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: /srv/ccengine/src/{{ repo }}
    - rev: {{ pillar.ccengine.branch }}
    - branch: {{ pillar.ccengine.branch }}
    - fetch_tags: False
    - require:
      - file: {{ sls }} /srv/ccengine/src
      - pkg: ccengine installed packages
{%- endfor %}
