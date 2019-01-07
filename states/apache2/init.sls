{% import "apache2/jinja2.sls" as a2 with context -%}

{% set CONFS_INSTALL = ["zzz_denied_to_all", "zzz_harden"] -%}
{% set CONFS_DISABLE = ["other-vhosts-access-log", "security",
                        "serve-cgi-bin"] -%}
{% set MODS_ENABLE = salt["pillar.get"]("apache2:mods:enable", []) -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2
    - require:
      - mount: mount mount /var/www


{{ sls }} service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ a2.disable_confs(sls, CONFS_DISABLE) }}


{{ a2.install_confs(sls, CONFS_INSTALL) }}


{{ a2.enable_mods(sls, MODS_ENABLE) }}
