# - Members of user:webdevs are added to thye www-data Linux system group
# - Members of user:admins are added to the www-data Linux system group
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
{%- if pillar.mounts %}
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} www-data group:
  group.present:
    - name: www-data
    - gid: 33
{%- set admins = salt["pillar.get"]("user:admins", false) %}
{%- set webdevs = salt["pillar.get"]("user:webdevs", false) %}
{%- if admins or webdevs %}
    - addusers:
{%- if admins %}
{%- for user in admins.keys() %}
      - {{ user }}
{%- endfor %}
{%- endif %}
{%- if webdevs %}
{%- for user in webdevs.keys() %}
      - {{ user }}
{%- endfor %}
{%- endif %}
{%- endif %}
    - require:
      - pkg: {{ sls }} installed packages



{{ sls }} service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ a2.disable_confs(sls, CONFS_DISABLE) -}}
{{ a2.install_confs(sls, CONFS_INSTALL) -}}
{{ a2.enable_mods(sls, MODS_ENABLE) -}}
