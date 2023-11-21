# Also see states/salt/init.sls for logic determining version on salt-prime
# and Debian 12 (bookworm)
{% if grains['osmajorrelease'] > 11 -%}
  salt:
    minion_target_version: 3006.4
{%- else %}
  salt:
    minion_target_version: 3005.2+ds-1
{%- endif %}
