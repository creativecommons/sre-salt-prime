{% macro tags(name, pod, key1, key2) -%}
- tags:
        Name: {{ name }}
        cc:pod: {{ pod }}
{{- infra_dict("aws", "tags", key1, key2) }}
{%- endmacro %}


{% macro infra_dict(sls, path, hst, pod) -%}
{% set hst__pod = "{}__{}".format(hst, pod) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_hst = ("infra:{}:{}:{}".format(sls, path, hst)) -%}
{% set k_hst__pod = ("infra:{}:{}:{}".format(sls, path, hst__pod)) -%}
{% set v_default = salt["pillar.get"](k_default, None) -%}
{% if v_default is none -%}
{{ raise("ERROR: missing default for: infra_dictlist({}, {}, {}, {})"
         .format(sls, path, hst, pod)) -}}
{% endif -%}
{% set v_hst = salt["pillar.get"](k_hst, v_default) -%}
{% set v_hst__pod = salt["pillar.get"](k_hst__pod, v_hst) -%}
{% for key, value in v_hst__pod.items() %}
        {{ key }}: {{ value -}}
{% endfor %}
{% endmacro -%}


{% macro infra_dictlist(sls, path, hst, pod) -%}
{% set hst__pod = "{}__{}".format(hst, pod) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_hst = ("infra:{}:{}:{}".format(sls, path, hst)) -%}
{% set k_hst__pod = ("infra:{}:{}:{}".format(sls, path, hst__pod)) -%}
{% set v_default = salt["pillar.get"](k_default, None) -%}
{% if v_default is none -%}
{{ raise("ERROR: missing default for: infra_dictlist({}, {}, {}, {})"
         .format(sls, path, hst, pod)) -}}
{% endif -%}
{% set v_hst = salt["pillar.get"](k_hst, v_default) -%}
{% set v_hst__pod = salt["pillar.get"](k_hst__pod, v_hst) -%}
{% for key, value in v_hst__pod.items() %}
      - {{ key }}: {{ value -}}
{% endfor %}
{% endmacro -%}


{% macro infra_list(sls, path, hst, pod) -%}
{% set hst__pod = "{}__{}".format(hst, pod) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_hst = ("infra:{}:{}:{}".format(sls, path, hst)) -%}
{% set k_hst__pod = ("infra:{}:{}:{}".format(sls, path, hst__pod)) -%}
{% set v_default = salt["pillar.get"](k_default, None) -%}
{% if v_default is none -%}
{{ raise("ERROR: missing default for: infra_list({}, {}, {}, {})"
         .format(sls, path, hst, pod)) -}}
{% endif -%}
{% set v_hst = salt["pillar.get"](k_hst, v_default) -%}
{% set v_hst__pod = salt["pillar.get"](k_hst__pod, v_hst) -%}
{% for item in v_hst__pod %}
      - {{ item -}}
{% endfor %}
{% endmacro -%}


{% macro infra_value(sls, path, hst, pod) -%}
{% set hst__pod = "{}__{}".format(hst, pod) -%}
{% set k_default = ("infra:{}:{}:default".format(sls, path)) -%}
{% set k_hst = ("infra:{}:{}:{}".format(sls, path, hst)) -%}
{% set k_hst__pod = ("infra:{}:{}:{}".format(sls, path, hst__pod)) -%}
{% set v_default = salt["pillar.get"](k_default, None) -%}
{% if v_default is none -%}
{{ raise("ERROR: missing default for: infra_list({}, {}, {}, {})"
         .format(sls, path, hst, pod)) -}}
{% endif -%}
{% set v_hst = salt["pillar.get"](k_hst, v_default) -%}
{% set v_hst__pod = salt["pillar.get"](k_hst__pod, v_hst) -%}
{% if v_hst__pod == "ABSENT" -%}
{{ "~" -}}
{% else -%}
{{ v_hst__pod -}}
{% endif -%}
{% endmacro -%}
