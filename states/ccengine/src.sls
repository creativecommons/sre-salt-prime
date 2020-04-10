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


{%- for path in (".git", "cc/i18n/mo", "cc/i18n/po") %}


{{ sls }} cc.i18n {{ path }} ownership and permissions:
  file.directory:
    - name: /srv/ccengine/src/cc.i18n/{{ path }}
    - user: www-data
    - group: www-data
    - dir_mode: '2775'
    - file_mode: '0664'
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: {{ sls }} cc.i18n repo
      - group: apache2 www-data group
{%- endfor %}


{{ sls }} cc.i18n cc/i18n/transstats.csv ownership and permissions:
  file.managed:
    - name: /srv/ccengine/src/cc.i18n/cc/i18n/transstats.csv
    - user: www-data
    - group: www-data
    - mode: '0664'
    - replace: False
    - create: False
    - require:
      - git: {{ sls }} cc.i18n repo
      - group: apache2 www-data group
