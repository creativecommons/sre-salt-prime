{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% set WEBNAME = "stage.creativecommons.org" -%}


include:
  - 5_HST__POD.ccorg__stage.secrets


ccorg:
  branch: main
letsencrypt:
  domainsets:
    {{ WEBNAME }}:
      - {{ WEBNAME }}
mysql:
  # (also see 5_HST__POD.ccorg__stage.secrets)
  server:
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.ccorg__stage.secrets)
  #canonical: https://{{ WEBNAME }}
  docroot: /var/www/{{ WEBNAME }}
  site: {{ WEBNAME }}
  db_host: {{ ENDPOINT }}
  wp_debug: False
