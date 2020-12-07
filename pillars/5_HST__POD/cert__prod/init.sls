{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
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
