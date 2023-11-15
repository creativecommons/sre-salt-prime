{% if grains['osmajorrelease'] > 11 %}
  salt:
    minion_target_version: 3006.4+ds-1
{% else %}
  salt:
    minion_target_version: 3005.2+ds-1
{% endif %}
