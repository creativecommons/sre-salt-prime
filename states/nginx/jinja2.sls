{# Install and Enable nginx configs -#}
{% macro install_confs(sls, confs) -%}
{% for conf in confs -%}
{{ sls }} install conf {{ conf }}:
  file.managed:
    - name: /etc/nginx/conf.d/{{ conf }}.conf
    - source: salt://nginx/files/{{ conf }}.conf
    - mode: '0444'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{% endfor -%}
{% endmacro -%}


{# Disable nginx mods -#}
{% macro disable_mods(sls, mods) -%}
{% for mod in mods -%}
{{ sls }} disable mod {{ mod }}:
  file.absent:
    - name: /etc/nginx/mods-enabled/{{ mod }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{% endfor -%}
{% endmacro -%}


{# Disable nginx sites -#}
{% macro disable_sites(sls, sites) -%}
{% for site in sites -%}
{{ sls }} disable site {{ site }}:
  file.absent:
    - name: /etc/nginx/sites-enabled/{{ site }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{% endfor -%}
{% endmacro -%}


{# Enable nginx sites -#}
{% macro enable_sites(sls, sites) -%}
{% for site in sites -%}
{{ sls }} enable site {{ site }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ site }}
    - target: /etc/nginx/sites-available/{{ site }}
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{% endfor -%}
{% endmacro -%}


{# Install nginx sites -#}
{% macro install_sites(sls, sites) -%}
{% for site in sites -%}
{{ sls }} install site {{ site }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ site }}
    - source: salt://nginx/files/{{ site }}
    - mode: '0444'
    - require:
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{{ sls }} enable site {{ site }}:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ site }}
    - target: /etc/nginx/sites-available/{{ site }}
    - require:
      - file: {{ sls }} install site {{ site }}
      - pkg: nginx installed packages
    - watch_in:
      - service: nginx service


{% endfor -%}
{% endmacro -%}
