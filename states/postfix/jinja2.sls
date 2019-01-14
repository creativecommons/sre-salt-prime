{# Install and Update postfix alias file -#}
{% macro install_alias(sls, mode, path, source) -%}
{{ sls }} update alias from {{ source }} file:
  cmd.wait:
    - name: postalias -v {{ path }}


{{ sls }} install alias source file {{ source }}:
  file.managed:
    - name: {{ path }}
    - source: salt://postfix/files/{{ source }}
    - mode: '{{ mode }}'
    - template: jinja
    - require:
      - pkg: postfix installed packages
    - watch_in:
      - cmd: {{ sls }} update alias from {{ source }} file


{% endmacro -%}


{# Install and Update postfix map file -#}
{% macro install_map(sls, mode, path, source) -%}
{{ sls }} update map from {{ source }} file:
  cmd.wait:
    - name: postmap -v {{ path }}


{{ sls }} install map source file {{ source }}:
  file.managed:
    - name: {{ path }}
    - source: salt://postfix/files/{{ source }}
    - mode: '{{ mode }}'
    - template: jinja
    - require:
      - pkg: postfix installed packages
    - watch_in:
      - cmd: {{ sls }} update map from {{ source }} file


{% endmacro -%}
