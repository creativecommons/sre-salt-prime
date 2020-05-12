{% import "nginx/jinja2.sls" as nginx with context -%}

{% set CONFS_INSTALL = ["zzz_harden"] -%}
{% set MODS_DISABLE = ["50-mod-http-echo.conf"] -%}


include:
  - tls


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - libnginx-mod-http-headers-more-filter
      - nginx-light
      - nginx-doc
    - require:
      - file: tls dhparams.pem


# If you edit this stanze, also edit the same stanza in states/apache2/init.sls
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
    - name: nginx
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} Enable vim sytnax highlighting:
  file.prepend:
    - name: /etc/nginx/nginx.conf
    - text: '# vim: ft=nginx noexpandtab:'
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service


# TLS/SSL configured in conf.d/zzz_harden.conf
{{ sls }} disable duplicated ssl_protocols:
  file.comment:
    - name: /etc/nginx/nginx.conf
    - regex: "^[\t ]ssl_protocols"
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service


# TLS/SSL configured in conf.d/zzz_harden.conf
{{ sls }} disable duplicated ssl_prefer_server_ciphers:
  file.comment:
    - name: /etc/nginx/nginx.conf
    - regex: "^[\t ]ssl_prefer_server_ciphers"
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service


{{ nginx.install_confs(sls, CONFS_INSTALL) -}}
{{ nginx.disable_mods(sls, MODS_DISABLE) -}}
