{% macro tags(ident) -%}
{% set name = ident|join("_") -%}
{% set pod = ident[1] -%}
- tags:
        Name: {{ name }}
        Pod: {{ pod }}
{%- endmacro %}


{% macro infra_dictlist(sls, path, requested) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_requested = ("infra:{}:{}:{}".format(sls, path, requested)) -%}
{% set v_default = salt["pillar.get"](k_default, "ERROR_infra_dictlist") -%}
{% for key, value in salt["pillar.get"](k_requested, v_default).items() %}
      - {{ key }}: {{ value -}}
{% endfor %}
{% endmacro -%}


{% macro infra_list(sls, path, requested) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_requested = ("infra:{}:{}:{}".format(sls, path, requested)) -%}
{% set v_default = salt["pillar.get"](k_default, "ERROR_infra_dictlist") -%}
{% for item in salt["pillar.get"](k_requested, v_default) %}
      - {{ item -}}
{% endfor %}
{% endmacro -%}


{% macro infra_value(sls, path, requested) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_requested = ("infra:{}:{}:{}".format(sls, path, requested)) -%}
{% set v_default = salt["pillar.get"](k_default, "ERROR_infra_value") -%}
{% set value  = salt["pillar.get"](k_requested, v_default) -%}
{% if value is none -%}
{{ "~" -}}
{% else -%}
{{ value -}}
{% endif -%}
{% endmacro -%}
