{% import_yaml "letsencrypt/secrets.yaml" as secrets -%}


letsencrypt:
  config:
    agree-tos: True
    authenticator: webroot
    eff-email: False
    email: {{ secrets.email }}
    expand: True
    keep-until-expiring: True
    renew-with-new-domains: True
    server: https://acme-v02.api.letsencrypt.org/directory
    webroot-path: /var/www/html
  {%- if grains.os == "Debian" and grains.osrelease|int == 11 %}
  {#- Debian 11 (Bullseye): only supports up to 4.2.0
     refer to https://github.com/creativecommons/tech-support/issues/1361 #}
  version: "4.2.0"
  {%- else %}
  version: "5.3.1"
  {%- endif %}
