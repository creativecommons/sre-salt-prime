{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set kwargs = {"name": [HST, POD, "rdsdb"]|join("-"), "region": LOC,
                 "jmespath": "DBInstances[0].Endpoint.Address"} -%}
{% set ENDPOINT = salt.boto_rds.describe_db_instances(**kwargs)[0] -%}


include:
  - 5_HST__POD.cert__prod.secrets


letsencrypt:
  domainsets:
    certificate.creativecommons.org:
      - certificate.creativecommons.org
mysql:
  # (also see 5_HST__POD.cert__prod.secrets)
  server:
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.cert__prod.secrets)
  canonical: https://certificate.creativecommons.org
  site: certificate.creativecommons.org
  db_host: {{ ENDPOINT }}
  wp_debug: False
