include:
  - wikijs.reports_shared


{{ sls }} gandi token:
  file.managed:
    - name: /srv/wikijs/.gandi_token
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - contents:
      - {{ pillar.gandi.api_key }}
    - require:
      - file: wikijs.reports_shared wikijs directory


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/gandi
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/gandi
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["GitPython", "requests"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/gandi
    - require:
      - pkg: python.pip installed packages
      - virtualenv: {{ sls }} virtualenv
    - require_in:
      - cron: {{ sls }} cron job
{%- endfor %}


{% set python3 = "/srv/wikijs/.venvs/gandi/bin/python3" -%}
{% set report = "/srv/wikijs/sre-report-to-wikijs/gandi/report.py" -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: gandi_report
    - minute: random
