{% macro tags(ident) -%}
{% set name = ident|join("_") -%}
{% set pod = ident[1] -%}
- tags:
        Name: {{ name }}
        Pod: {{ pod }}
{%- endmacro %}
