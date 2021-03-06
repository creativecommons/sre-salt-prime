{% set ID, HST, POD, LOC, POD__LOC, HST__POD = salt.meta.classify() -%}
{% set ENDPOINT = salt.meta.rds_endpoint() -%}
{% import_yaml "5_HST__POD/{}/secrets.yaml".format(HST__POD) as SECRETS -%}
{% import_yaml "letsencrypt/secrets.yaml" as LETSENCRYPT -%}


include:
  - 5_HST__POD.chapters__stage.secrets
  - cloudflare.secrets


letsencrypt:
  config:
    agree-tos: True
    authenticator: dns-cloudflare
    dns-cloudflare-credentials: /root/.secrets/cloudflare_api.ini
    eff-email: False
    email: {{ LETSENCRYPT.email }}
    expand: True
    keep-until-expiring: True
    preferred-challenges: dns-01
    renew-with-new-domains: True
    server: https://acme-v02.api.letsencrypt.org/directory
  domainsets:
    stage.creativecommons.net:
      - '*.stage.creativecommons.net'
mysql:
  server:
    root_user: {{ SECRETS.mysql.server.root_user }}
    root_password: {{ SECRETS.mysql.server.root_password }}
    host: {{ ENDPOINT }}
wordpress:
  site: stage.creativecommons.net
  # (also see 5_HST__POD.chapters__stage.secrets)
  # Database
  db_host: {{ ENDPOINT }}
  # Developer
  wp_debug: False
  # Multisite
  domain_current_site: stage.creativecommons.net
