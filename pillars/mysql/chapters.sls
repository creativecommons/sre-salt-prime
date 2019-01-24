{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}


include:
  - mysql


{% import 'mysql/chapters_secrets.yaml' as mysql -%}
{{ mysql }}
    host: {{ ENDPOINT }}
