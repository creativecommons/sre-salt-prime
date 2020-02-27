{% import "nginx/jinja2.sls" as nginx with context -%}
{% set CONFS_INSTALL = ["custom_log_formats", "real_ip_from_cloudflare"] -%}
{% set NOW = None|strftime("%Y%m%d_%H%M%S") -%}


include:
  - logrotate.nginx_custom_logs


{{ sls }} custom log dir:
  file.directory:
    - name: {{ pillar.nginx.custom_log_dir }}
    - group: adm
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} /var/log symlink:
  file.symlink:
    - name: /var/log/nginx-custom
    - target: {{ pillar.nginx.custom_log_dir }}
    - force: True
    - backupname: /var/log/nginx-custom.{{ NOW }}
    - require:
      - file: {{ sls }} custom log dir


{{ nginx.install_confs(sls, CONFS_INSTALL) -}}
