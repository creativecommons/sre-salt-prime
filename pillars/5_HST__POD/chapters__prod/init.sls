{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}
{% import_yaml "5_HST__POD/{}/secrets.yaml".format(HST__POD) as SECRETS -%}


include:
  - 5_HST__POD.chapters__prod.secrets


letsencrypt:
  domainsets:
    chapters:
      - chapters.creativecommons.org
      - au-beta.creativecommons.org
      - ca-beta.creativecommons.org
      - ke-beta.creativecommons.org
      - mx-beta.creativecommons.org
      - nl-beta.creativecommons.org
mysql:
  server:
    root_user: {{ SECRETS.mysql.server.root_user }}
    root_password: {{ SECRETS.mysql.server.root_password }}
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.chapters__prod.secrets)
  # Database
  db_host: {{ ENDPOINT }}
  # Developer
  wp_debug: False
  # Multisite
  domain_current_site: chapters.creativecommons.org
