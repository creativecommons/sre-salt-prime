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
{%- if pillar.mounts %}
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}
    - require_in:
      - pkg: apache2 installed packages
      - pip: letsencrypt install certbot
