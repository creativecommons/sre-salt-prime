{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% import_yaml "5_HST__POD/{}/secrets.yaml".format(HST__POD) as SECRETS -%}


include:
  - 5_HST__POD.ccorgwp__stage.secrets


ccorg:
  branch: staging
mysql:
  server:
    root_user: {{ SECRETS.mysql.server.root_user }}
    root_password: {{ SECRETS.mysql.server.root_password }}
    host: {{ ENDPOINT }}
wordpress:
  site: stage.creativecommons.org
  # (also see 5_HST__POD.ccorgwp__stage.secrets)
  # Database
  db_host: {{ ENDPOINT }}
  table_prefix: mattl_
  # Developer
  wp_debug: False
