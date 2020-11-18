{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}
{% set WEBNAME = "tempcert.creativecommons.org" -%}


include:
  - 5_HST__POD.cert__prod.secrets


letsencrypt:
  domainsets:
    {{ WEBNAME }}:
      - {{ WEBNAME }}
mysql:
  # (also see 5_HST__POD.cert__prod.secrets)
  server:
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.cert__prod.secrets)
  advanced-custom-fields-pro:
    repo:
    version: 5.9.1
  #canonical: https://{{ WEBNAME }}
  site: {{ WEBNAME }}
  db_host: {{ ENDPOINT }}
  wp_debug: False
  # Multisite
  domain_current_site: {{ WEBNAME }}
