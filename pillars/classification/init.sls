{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% import_yaml "infra/networks.yaml" as networks %}
hst: {{ HST }}
pod: {{ POD }}
loc: {{ LOC }}
net: {{ networks.networks[POD__LOC] }}
