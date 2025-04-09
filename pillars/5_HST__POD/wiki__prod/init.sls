{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% set WEBNAME = "newwikicreativecommons.org" -%

include:
  - 5_HST__POD.wiki__prod.secrets


mysql:
  # (also see 5_HST__POD.wiki__prod.secrets)
  server:
    host: {{ ENDPOINT }}
