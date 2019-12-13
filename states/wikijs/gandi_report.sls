include:
  - python.pip


{{ sls }} gandi token:
  file.managed:
    - name: /srv/wikijs/.gandi_token
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - contents:
      - {{ pillar.gandi.api_key }}
    - require:
      - file: wikijs.reports wikijs directory


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/gandi
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/gandi
    - require:
      - file: wikijs.reports wikijs .venvs directory


{{ sls }} GitPython:
  pip.installed:
    - name: GitPython
    - bin_env: /srv/wikijs/.venvs/gandi
    - require:
      - pkg: python.pip installed packages
      - virtualenv: {{ sls }} virtualenv


{{ sls }} requests:
  pip.installed:
    - name: requests
    - bin_env: /srv/wikijs/.venvs/gandi
    - require:
      - pkg: python.pip installed packages
      - virtualenv: {{ sls }} virtualenv


{% set python3 = "/srv/wikijs/.venvs/gandi/bin/python3" -%}
{% set report = "/srv/wikijs/sre-report-to-wikijs/gandi/report.py" -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: gandi_report
    - special: "@hourly"
    - require:
      - pip: {{ sls }} GitPython
      - pip: {{ sls }} requests
