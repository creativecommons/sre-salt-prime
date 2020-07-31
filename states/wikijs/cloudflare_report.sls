include:
  - wikijs.reports_shared


{{ sls }} cloudflare email:
  file.managed:
    - name: /srv/wikijs/.cloudflare_email
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - contents:
      - {{ pillar.cloudflare.email }}
    - require:
      - file: wikijs.reports_shared wikijs directory


{{ sls }} cloudflare token:
  file.managed:
    - name: /srv/wikijs/.cloudflare_token
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - contents:
      - {{ pillar.cloudflare.api_key }}
    - require:
      - file: wikijs.reports_shared wikijs directory


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/cloudflare
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/cloudflare
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["cloudflare", "GitPython"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/cloudflare
    - require:
      - virtualenv: {{ sls }} virtualenv
    - require_in:
      - cron: {{ sls }} cron job
{%- endfor %}


{% set python3 = "/srv/wikijs/.venvs/cloudflare/bin/python3" -%}
{% set report = "/srv/wikijs/sre-report-to-wikijs/cloudflare/report.py" -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: cloudflare_report
    - minute: random
