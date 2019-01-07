letsencrypt:
  config: |
    server = https://acme-v02.api.letsencrypt.org/directory
    email = webmaster@creativecommons.org
    authenticator = webroot
    webroot-path = /var/www/html
    agree-tos = True
    renew-by-default = True
  use_package: false
  version: 0.30.x
