{% set SECRET = "/srv/wikijs/.workspace_service_account_secret.json" -%}

include:
  - wikijs.reports_shared


{{ sls }} workspace service account secret:
  file.managed:
    - name: {{ SECRET }}
    - source: salt://wikijs/files/workspace_service_account_secret.json
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - require:
      - file: wikijs.reports_shared wikijs directory


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/workspace
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/workspace
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["GitPython", "google-api-python-client",
                    "google-auth-oauthlib"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/workspace
    - require:
      - pkg: python.pip installed packages
      - virtualenv: {{ sls }} virtualenv
    - require_in:
      - cron: {{ sls }} groups cron job
      - cron: {{ sls }} users cron job
{%- endfor %}


{%- for report in ["groups", "users"] %}


{% set python3 = "/srv/wikijs/.venvs/workspace/bin/python3" -%}
{% set run_report = (
  "{} /srv/wikijs/sre-report-to-wikijs/workspace/report-{}.py"
  .format(python3, report)
) -%}
{{ sls }} {{ report }} cron job:
  cron.present:
    - name: {{ run_report }} --secret-file={{ SECRET }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: workspace_{{report}}_report
    - minute: random
{%- endfor %}
