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
  {%- if grains.pythonversion[1] == 5 %}
  {#- last supported version on Python 3.5 #}
  version: "1.7.0"
  {%- else %}
  version: "1.22.0"
  {%- endif %}
