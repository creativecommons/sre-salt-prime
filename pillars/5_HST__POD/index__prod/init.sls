{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% set WEBNAME = "creativecommons.org" -%}

include:
  - 5_HST__POD.index__prod.secrets


index:
  branch: main
letsencrypt:
  domainsets:
    {{ WEBNAME }}:
      - {{ WEBNAME }}
mysql:
  # (also see 5_HST__POD.index__prod.secrets)
  server:
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.index__prod.secrets)
  #canonical: https://{{ WEBNAME }}
  db_host: {{ ENDPOINT }}
  site: {{ WEBNAME }}
  title: Creative Commons
  wp_debug: False
