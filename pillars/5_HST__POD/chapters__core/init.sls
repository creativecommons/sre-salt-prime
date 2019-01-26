{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}


letsencrypt:
  domainsets:
    chapters:
      - chapters.creativecommons.org
{% import "5_HST__POD/{}/secrets.yaml".format(HST__POD) as mysql -%}
{{ mysql }}
    host: {{ ENDPOINT }}
