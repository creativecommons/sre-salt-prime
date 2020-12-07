{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}


include:
  - 5_HST__POD.opencovid__prod.secrets


letsencrypt:
  domainsets:
    opencovidpledge.org:
      - opencovidpledge.org
      - www.opencovidpledge.org
mysql:
  # (also see 5_HST__POD.opencovid__prod.secrets)
  server:
    host: {{ ENDPOINT }}
wordpress:
  # (also see 5_HST__POD.opencovid__prod.secrets)
  canonical: https://opencovidpledge.org
  site: opencovidpledge.org
  db_host: {{ ENDPOINT }}
  wp_debug: False
