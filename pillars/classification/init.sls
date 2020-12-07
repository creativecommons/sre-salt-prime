{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% import_yaml "/srv/{}/pillars/infra/networks.yaml".format(saltenv) as nets %}
hst: {{ HST }}
pod: {{ POD }}
loc: {{ LOC }}
net: {{ nets[POD__LOC] }}
