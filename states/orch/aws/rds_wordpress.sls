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
{% set NET = pillar.tgt_net -%}

{% set P_SLS = pillar.infra[sls] -%}
{% set P_LOC = pillar.infra[LOC] -%}
{% set P_NET = P_LOC[NET] -%}

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
    - description: {{ name }}
    - subnet_names:
{{- aws.infra_list(sls, "rds_subnets", HST, POD) }}{{ "    " -}}
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
    - db_parameter_group_family: >-
        {{ aws.infra_value(sls, "engine_family", HST, POD) }}
    - parameters:
{{- aws.infra_dictlist(sls, "parameters", HST, POD) }}{{ "    " -}}
    {{ aws.tags(ident) }}


# "[DBInstanceIdentifier] must begin with a letter; must contain only ASCII
# letters, digits, and hyphens; and must not end with a hyphen or contain two
# consecutive hyphens"
{% set ident = [HST, POD, "rdsdb"] -%}
{% set name = ident|join("-") -%}
{{ name }}:
  boto_rds.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - allocated_storage: {{ aws.infra_value(sls, "storage", HST, POD) }}
    - db_instance_class: {{ aws.infra_value(sls, "instance_class", HST, POD) }}
    - engine: {{ aws.infra_value(sls, "engine", HST, POD) }}
    - master_username: {{ aws.infra_value(sls, "primary_username", HST, POD) }}
    - master_user_password: >-
        {{ aws.infra_value(sls, "primary_password", HST, POD) }}
    - storage_type: gp2
    - vpc_security_groups:
{{- aws.infra_list(sls, "secgroups", HST, POD) }}{{ "    " -}}
    - availability_zone: {{ P_NET.subnets["private-one"]["az"] }}
    - db_subnet_group_name: {{ name_subnetgroup }}
    - preferred_maintenance_window: Sun:06:00-Sun:07:00
    - db_parameter_group_name: {{ name_parameter }}
    - storage_encrypted: True
    - kms_keyid: {{ KMS_KEY_STORAGE }}
    - backup_retention_period: 35
    - preferred_backup_window: 05:00-06:00
    - port: 3306
    - engine_version: {{ aws.infra_value(sls, "engine_version", HST, POD) }}
    - auto_minor_version_upgrade: True
    - publicly_accessible: False
    - wait_status: available
    {{ aws.tags(ident) }}
    - require:
      - boto_rds: {{ name_parameter }}
      - boto_rds: {{ name_subnetgroup }}
