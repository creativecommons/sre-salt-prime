{% import "apache2/jinja2.sls" as a2 with context -%}

{% set CONFS_INSTALL = ["denied_to_all", "harden"] -%}
{% set MODS_ENABLE = ["rewrite", "ssl"] -%}
{% set CONFS_DISABLE = ["serve-cgi-bin"] -%}


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


{{ a2.disable_confs(sls, CONFS_DISABLE) }}


{{ a2.install_confs(sls, CONFS_INSTALL) }}


{{ a2.enable_mods(sls, MODS_ENABLE) }}
