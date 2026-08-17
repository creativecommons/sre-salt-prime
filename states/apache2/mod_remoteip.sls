{% import "apache2/jinja2.sls" as a2 with context -%}


{{ a2.enable_mods(sls, ["remoteip"]) -}}
{{ a2.install_confs(sls, ["remoteip"]) -}}
