include:
  - wikijs.reports_shared


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/gsuite
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/gsuite
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["google-api-python-client", "google-auth-httplib2",
                    "google-auth-oauthlib"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/gsuite
    - require:
      - virtualenv: {{ sls }} virtualenv
    #- require_in:
      #- cron: {{ sls }} cron job
{%- endfor %}


{#
{%- for report in ["users"] %}


{% set python3 = "/srv/wikijs/.venvs/gsuite/bin/python3" -%}
{% set report_path = ("/srv/wikijs/sre-report-to-wikijs/gsuite/report-{}.py"
                      .format(report)) -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report_path }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: gsite_{{report}}_report
    - special: "@hourly"
{%- endfor %}
#}
