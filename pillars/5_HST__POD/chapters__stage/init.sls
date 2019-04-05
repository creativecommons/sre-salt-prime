{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}
{% import_yaml "5_HST__POD/{}/secrets.yaml".format(HST__POD) as SECRETS -%}


include:
  - 5_HST__POD.chapters__stage.secrets


letsencrypt:
  domainsets:
    chapters:
      - chapters-stage.creativecommons.org
mysql:
  server:
    root_user: {{ SECRETS.mysql.server.root_user }}
    root_password: {{ SECRETS.mysql.server.root_password }}
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.chapters__stage.secrets)
  # Database
  db_host: {{ ENDPOINT }}
  # Developer
  wp_debug: False
  # Multisite
  domain_current_site: chapters-stage.creativecommons.org
