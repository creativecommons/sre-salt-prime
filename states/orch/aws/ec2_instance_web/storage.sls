# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
# optional command line pillar data:
#   kms_key_storage: KMS Key ID ARN
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set CONF_SLS = pillar.conf_sls -%}
{% set KMS_KEY_STORAGE = pillar.kms_key_storage -%}
{% set instance_ident = [HST, POD, LOC] -%}
{% set instance_name = instance_ident|join("_") -%}
{% set ID = salt.boto_ec2.get_id(region=LOC, name=instance_name) -%}


# Set ebs_size to ABSENT to disable creation of xvdf
{% set xvdf_size = aws.infra_value(CONF_SLS, "ebs_size", HST, POD) -%}
{% if xvdf_size != "~" -%}
{% set ident = [HST, POD, "ebs-xvdf"] -%}
{% set name = ident|join("_") -%}
{% set name_ebs = name -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_id: {{ ID }}
    - device: xvdf
    - size: {{ xvdf_size }}
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: {{ KMS_KEY_STORAGE }}
{%- endif %}


# If we have a valid instance ID, ensure both the xvda and xvdf volumes are
# tagged (without this stanza, the only volume tag is Name on xvdf).
#
# For filters information, see:
# https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.boto_ec2.html#salt.modules.boto_ec2.get_all_volumes
{%- if ID and ID is not none %}
{%- for device in ["/dev/xvda", "xvda", "xvdf"] %}


{% set ident = [HST, POD, "ebs-{}".format(device.replace("/dev/", "dev-"))] -%}
{% set name = ident|join("_") -%}
{{ name }}-tagged:
{%- set name = name.replace("dev-", "") %}
  boto_ec2.volumes_tagged:
    - region: {{ LOC }}
    - name: {{ name }}
    - tag_maps:
      - filters:
          attachment.device: {{ device }}
          attachment.instance_id: {{ ID }}
        tags:
          Name: {{ name }}
          cc:pod: {{ POD }}
{{- aws.infra_dict("aws", "tags", HST, POD, indent=10) }}
{%- endfor %}
{%- endif %}
