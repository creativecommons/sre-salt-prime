letsencrypt:
  config: |
    agree-tos = True
    authenticator = webroot
    eff-email = True
    email = webmaster@creativecommons.org
    expand = True
    keep-until-expiring = True
    quiet = True
    renew-with-new-domains = True
    server = https://acme-v02.api.letsencrypt.org/directory
    webroot-path = /var/www/html
  use_package: false
  version: 0.30.x
