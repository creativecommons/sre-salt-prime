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
linux:
  # 1. r8a.medium supports 314 workers per states/apache2/mpm_prefork.sls
  # 2. Assuming 8M per worker + PHP memory_lmit = 128M
  # 3. ( 8 + 128 ) * 314 = 42,704
  # 4. Rounding 42,704 up to 64,000M
  # 5. states/swapfile/init.sls expects G
  swapsize: 64
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
