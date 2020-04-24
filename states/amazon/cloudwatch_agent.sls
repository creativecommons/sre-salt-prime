{#
Ideally we would use the region reported by the minion. However there appears
to be a bug:
  dynamic:instance-identity:document grain is not parsed on Debian 10 Buster -
  Issue #56886
  https://github.com/saltstack/salt/issues/56886

{% set REGION_KEY = "dynamic:instance-identity:document:region" -%}
{% set REGION = salt["grains.get"](REGION_KEY) -%}
#}
{% set REGION = pillar.loc -%}
{% if REGION -%}


{{ sls }} installed packages:
  pkg.installed:
    - refresh: False
    - sources:
      - amazon-cloudwatch-agent: https://s3.{{ REGION }}.amazonaws.com/amazoncloudwatch-agent-{{ REGION }}/debian/amd64/latest/amazon-cloudwatch-agent.deb


{{ sls }} config file:
  file.managed:
    - name: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    - source: salt://amazon/files/amazon-cloudwatch-agent.json
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service


{{ sls }} service:
  service.running:
    - name: amazon-cloudwatch-agent
    - enable: True
    - require:
      - file: {{ sls }} config file


{%- endif %}
