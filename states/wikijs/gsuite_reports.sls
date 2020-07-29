include:
  - wikijs.reports_shared


{{ sls }} gsuite service account secret:
  file.managed:
    - name: /srv/wikijs/.gsuite_service_account_secret.json
    - source: salt://wikijs/files/gsuite_service_account_secret.json
    - user: wikijs
    - group: wikijs
    - mode: '0400'
    - require:
      - file: wikijs.reports_shared wikijs directory


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/gsuite
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/gsuite
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["GitPython", "google-api-python-client",
                    "google-auth-oauthlib"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/gsuite
    - require:
      - virtualenv: {{ sls }} virtualenv
    - require_in:
      - cron: {{ sls }} groups cron job
      - cron: {{ sls }} users cron job
{%- endfor %}


{%- for report in ["groups", "users"] %}


{% set python3 = "/srv/wikijs/.venvs/gsuite/bin/python3" -%}
{% set report_path = ("/srv/wikijs/sre-report-to-wikijs/gsuite/report-{}.py"
                      .format(report)) -%}
{{ sls }} {{ report }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report_path }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: gsite_{{report}}_report
    - special: "@hourly"
{%- endfor %}
