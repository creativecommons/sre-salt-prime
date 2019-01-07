letsencrypt:
  version: v0.30.0
  use_package: false
  config: |
    server = https://acme-v02.api.letsencrypt.org/directory
    email = webmaster@creativecommons.org
    authenticator = webroot
    webroot-path = /var/www/html
    agree-tos = True
    renew-by-default = True
