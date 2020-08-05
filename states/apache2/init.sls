# - Members of user:webdevs are added to thye www-data Linux system group
# - Members of user:admins are added to the www-data Linux system group
{% import "apache2/jinja2.sls" as a2 with context -%}

{% set CONFS_INSTALL = ["zzz_denied_to_all", "zzz_harden"] -%}
{% set CONFS_DISABLE = ["other-vhosts-access-log", "security",
                        "serve-cgi-bin"] -%}
{% set MODS_ENABLE = salt["pillar.get"]("apache2:mods:enable", []) -%}


include:
  - apache2.mpm_prefork


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


# If you edit this stanze, also edit the same stanza in states/nginx/init.sls
{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}
{% set webdevs = salt["pillar.get"]("user:webdevs", {}).keys()|sort -%}
{% set users = admins + webdevs|sort -%}
{{ sls }} www-data group:
  group.present:
    - name: www-data
    - gid: 33
{%- if users %}
    - addusers:
{%- for username in users %}
      - {{ username }}
{%- endfor %}
{%- endif %}
    - require:
      - pkg: {{ sls }} installed packages
{%- if admins %}
{%- for username in admins %}
      - user: user.admins {{ username }} user
{%- endfor %}
{%- endif %}
{%- if webdevs %}
{%- for username in webdevs %}
      - user: user.webdevs {{ username }} user
{%- endfor %}
{%- endif %}


{{ sls }} service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ a2.disable_confs(sls, CONFS_DISABLE) -}}
{{ a2.install_confs(sls, CONFS_INSTALL) -}}
{{ a2.enable_mods(sls, MODS_ENABLE) -}}
