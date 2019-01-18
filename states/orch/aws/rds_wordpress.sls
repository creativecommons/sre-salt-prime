# Required command line pillar data:
#   tgt_hst: Targeted Hostname and Wiki
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
# optional command line pillar data:
#   kms_key_storage: KMS Key ID ARN
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_SLS = pillar.infra[sls] -%}
{% set P_LOC = pillar.infra[LOC] -%}
{% set P_POD = P_LOC[POD] -%}

{% if "kms_key_storage" in pillar -%}
{% set KMS_KEY_STORAGE = pillar.kms_key_storage -%}
{% else -%}
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{# The region must NOT be omitted from the KMS Key ID -#}
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", ACCOUNT_ID,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}
{% endif -%}


### RDS


{% set ident = [HST, POD, "subnet-group"] -%}
{% set name = ident|join("_") -%}
{% set name_subnetgroup = name -%}
{{ name }}:
  boto_rds.subnet_group_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: "{{ POD }} {{ HST }} RDS Subnet Group in {{ LOC }}"
    - subnet_names:
{%- set subnets_key = ("infra:{}:subnets:{}".format(sls, HST)) -%}
{% set subnets_default = P_SLS["subnets"]["default"] -%}
{% for subnet in salt["pillar.get"](subnets_key, subnets_default) %}
      - {{ subnet -}}
{% endfor %}
    {{ aws.tags(ident) }}


# RDS Parameter groups "Must contain only letters, digits, or hyphens".
# Additionally, two ore more hyphens in a row will result in failure.
{% set ident = [HST, POD, "rdsparameters"] -%}
{% set name = ident|join("-") -%}
{% set name_parameter = name -%}
{{ name }}:
  boto_rds.parameter_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ ident|join("_") }}
{%- set family_key = ("infra:{}:instance_family:{}".format(sls, HST)) -%}
{% set family_default = P_SLS["family"]["default"] -%}
{% set family = salt["pillar.get"](family_key, family_default) %}
    - db_parameter_group_family: {{ family }}
    - parameters:
{%- set params_key = ("infra:{}:parameters:{}".format(sls, HST)) -%}
{% set params_default = P_SLS["parameters"]["default"] -%}
{% for key, value in salt["pillar.get"](params_key, params_default).items() %}
      - {{ key }}: {{ value -}}
{% endfor %}
    {{ aws.tags(ident) }}
