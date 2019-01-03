{# Install and Enable Apache2 configs -#}
{% macro install_confs(sls, confs) -%}
{% for conf in confs -%}
{{ sls }} install conf {{ conf }}:
  file.managed:
    - name: /etc/apache2/conf-available/{{ conf }}.conf
    - source: salt://apache2/files/{{ conf }}.conf
    - mode: '0444'
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: service_apache2


{{ sls }} enable conf {{ conf }}:
  apache_conf.enabled:
    - name: {{ conf }}
    - require:
      - file: {{ sls }} install conf {{ conf }}
    - watch_in:
      - service: service_apache2
{% endfor -%}
{% endmacro -%}


{# Enable Apache2 module -#}
{% macro enable_mods(sls, mods) -%}
{% for mod in mods -%}
{{ sls }} enable mod {{ mod }}:
  apache_module.enabled:
    - name: {{ mod }}
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: service_apache2
{% endfor -%}
{% endmacro -%}
