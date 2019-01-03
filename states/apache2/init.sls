{% import "apache2/jinja2.sls" as a2 with context -%}

{% set confs = ["denied_to_all", "harden"] -%}
{% set mods = ["rewrite", "ssl"] -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2
    - require:
      - mount: mount mount /var/www


service_apache2:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ a2.install_confs(sls, confs) }}


{{ a2.enable_mods(sls, mods) }}
