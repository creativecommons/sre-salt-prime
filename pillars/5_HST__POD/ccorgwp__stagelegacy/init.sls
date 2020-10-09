{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}


include:
  - 5_HST__POD.ccorgwp__stagelegacy.secrets


ccorg:
  branch: master
mysql:
  server:
    host: {{ ENDPOINT }}
wordpress:
  site: legacy.creativecommons.org
  db_host: {{ ENDPOINT }}
  table_prefix: mattl_
  wp_debug: False
