{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% import_yaml "/srv/{}/pillars/infra/networks.yaml".format(saltenv) as nets %}
hst: {{ HST }}
pod: {{ POD }}
loc: {{ LOC }}
net: {{ nets[POD__LOC] }}
