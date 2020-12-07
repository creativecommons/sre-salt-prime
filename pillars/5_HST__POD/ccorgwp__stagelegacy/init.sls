{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}


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
