{% import "nginx/jinja2.sls" as nginx with context -%}


include:
  - nginx


{{ nginx.disable_sites(sls, ["default"]) -}}
{{ nginx.install_sites(sls, ["wikijs.creativecommons.org"]) -}}
