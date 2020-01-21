
# States are selected via the pillar.states
#
# To see the states selected for minion, run:
#   sudo salt MINION\* pillar.item states
{{ saltenv }}:
  '{{ grains.id }}':
{% for state, pillar in pillar.states.items() %}
    - {{ state }}   # {{ pillar }}
{% endfor %}
