{# Disable Apache2 configs -#}
{% macro disable_confs(sls, confs) -%}
{% for conf in confs -%}
{{ sls }} disable conf {{ conf }}:
  apache_conf.disabled:
    - name: {{ conf }}
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}


{# Install and Enable Apache2 configs -#}
{% macro install_confs(sls, confs) -%}
{% for conf in confs -%}
{{ sls }} install conf {{ conf }}:
  file.managed:
    - name: /etc/apache2/conf-available/{{ conf }}.conf
    - source: salt://apache2/files/{{ conf }}.conf
    - mode: '0444'
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service


{{ sls }} enable conf {{ conf }}:
  apache_conf.enabled:
    - name: {{ conf }}
    - require:
      - file: {{ sls }} install conf {{ conf }}
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}


{# Disable Apache2 modules -#}
{% macro disable_mods(sls, mods) -%}
{% for mod in mods -%}
{{ sls }} disable mod {{ mod }}:
  apache_module.disabled:
    - name: {{ mod }}
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}


{# Enable Apache2 modules -#}
{% macro enable_mods(sls, mods) -%}
{% for mod in mods -%}
{{ sls }} enable mod {{ mod }}:
  apache_module.enabled:
    - name: {{ mod }}
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}


{# Disable Apache2 sites -#}
{% macro disable_sites(sls, sites) -%}
{% for site in sites -%}
{{ sls }} disable site {{ site }}:
  apache_site.disabled:
    - name: {{ site }}
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}


{# Enable Apache2 sites -#}
{% macro enable_sites(sls, sites) -%}
{% for site in sites -%}
{{ sls }} enable site {{ site }}:
  apache_site.enabled:
    - name: {{ site }}
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
{% endfor -%}
{% endmacro -%}
