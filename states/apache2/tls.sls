include:
  - apache2
  - apache2.mod_ssl
  - tls


{{ sls }} install tls before apache2 and letsencrypt:
  test.nop:
    - require:
      - file: tls dhparams.pem
    - require_in:
      - pkg: apache2 installed packages
      - pip: letsencrypt install certbot
