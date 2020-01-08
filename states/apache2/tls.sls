include:
  - apache2
  - apache2.mod_ssl
  - tls


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2
    - require:
      - file: tls dhparams.pem
    - require_in:
      - pkg: apache2 installed packages
      - pip: letsencrypt install certbot
