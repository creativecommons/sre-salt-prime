{{ sls }} virtualenv:
  virtualenv.managed:
    - name: /srv/wikijs/.venvs/amazon_route53
    - python: /usr/bin/python3
    - user: wikijs
    - cwd: /srv/wikijs/sre-report-to-wikijs/amazon_route53
    - require:
      - file: wikijs.reports wikijs .venvs directory


{{ sls }} boto3:
  pip.installed:
    - name: boto3
    - bin_env: /srv/wikijs/.venvs/amazon_route53
    - require:
      - virtualenv: {{ sls }} virtualenv


{{ sls }} GitPython:
  pip.installed:
    - name: GitPython
    - bin_env: /srv/wikijs/.venvs/amazon_route53
    - require:
      - virtualenv: {{ sls }} virtualenv


{% set python3 = "/srv/wikijs/.venvs/amazon_route53/bin/python3" -%}
{% set report = "/srv/wikijs/sre-report-to-wikijs/amazon-route53/report.py" -%}
{{ sls }} cron job:
  cron.present:
    - name: {{ python3 }} {{ report }} /srv/wikijs/sre-wiki-js
    - user: wikijs
    - identifier: amazon_route53_report
    - special: "@hourly"
    - require:
      - pip: {{ sls }} boto3
      - pip: {{ sls }} GitPython
