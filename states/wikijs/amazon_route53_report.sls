include:
  - wikijs.reports_shared


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/amazon_route53
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/amazon_route53
    - require:
      - file: wikijs.reports_shared wikijs .venvs directory
      - pkg: virtualenv installed packages


{%- for package in ["boto3", "GitPython"] %}


{{ sls }} {{ package }}:
  pip.installed:
    - name: {{ package }}
    - bin_env: /srv/wikijs/.venvs/amazon_route53
    - require:
      - virtualenv: {{ sls }} virtualenv
    - require_in:
      - cron: {{ sls }} cron job
{%- endfor %}


{% set python3 = "/srv/wikijs/.venvs/amazon_route53/bin/python3" -%}
{% set report = "/srv/wikijs/sre-report-to-wikijs/amazon-route53/report.py" -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: amazon_route53_report
    - minute: random
