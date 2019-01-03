{# Enable Apache2 config -#}
{% macro enable_confs(sls, confs) -%}
{% for conf in confs -%}
{{ sls }} enable conf {{ conf }}:
  apache_conf.enabled:
    - name: {{ conf }}
    - require:
      - file: {{ sls }} install conf {{ conf }}
    - watch_in:
      - service: service_apache2
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
    - watch_in:
      - service: service_apache2


{{ enable_confs(sls, [conf]) }}
{% endfor -%}
{% endmacro -%}


{# Enable Apache2 module -#}
{% macro enable_mods(sls, mods) -%}
{% for mod in mods -%}
{{ sls }} enable mod {{ mod }}:
  apache_module.enabled:
    - name: {{ mod }}
    - watch_in:
      - service: service_apache2
{% endfor -%}
{% endmacro -%}
