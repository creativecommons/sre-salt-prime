{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% import_yaml "5_HST__POD/{}/secrets.yaml".format(HST__POD) as SECRETS -%}


include:
  - 5_HST__POD.summit__prod.secrets


letsencrypt:
  domainsets:
    summit-temp.creativecommons.org:
      - summit-temp.creativecommons.org
mysql:
  server:
    root_user: {{ SECRETS.mysql.server.root_user }}
    root_password: {{ SECRETS.mysql.server.root_password }}
    host: {{ ENDPOINT }}
wordpress:
  site: summit-temp.creativecommons.org
  # (also see 5_HST__POD.summit__prod.secrets)
  # Database
  db_host: {{ ENDPOINT }}
  # Developer
  wp_debug: False
