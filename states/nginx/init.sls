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
