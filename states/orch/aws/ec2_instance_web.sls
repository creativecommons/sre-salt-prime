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
{% set NET = pillar.tgt_net -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}

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
{% set SUBNET = aws.infra_value(sls, "web_subnet", HST, POD) -%}
{% set SUBNET_NAME = [SUBNET, NET, "subnet"]|join("_") -%}


### EC2 Instance


# NOTE: Name is wrong. It ends with "secgroup" instead of "eni".
{% set ident = [HST, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ POD }} {{ HST }} ENI in {{ LOC }}
    - subnet_name: {{ SUBNET_NAME }}
    - private_ip_address: {{ P_NET["host_ips"][HST__POD] }}
    - groups:
{{- aws.infra_list(sls, "web_secgroups", HST, POD) }}{{ "    " -}}
    - allocate_eip: {{ aws.infra_value(sls, "allocate_eip", HST, POD) }}


{% set fqdn = (HST, "creativecommons.org")|join(".") -%}
{% set ident = [HST, POD, LOC] -%}
{% set name = ident|join("_") -%}
{% set name_instance = name -%}
{% set id = salt.boto_ec2.get_id(region=LOC, name=name) -%}
{{ name }}:
  boto_ec2.instance_present:
    - region: {{ LOC }}
    - name: {{ name }}
{%- if id is none %}
    - instance_name: {{ name }}
{%- else %}
    - instance_id: {{ id }}
{% endif %}
    - image_name: {{ P_LOC.debian_ami_name }}
    - key_name: {{ pillar.infra.provisioning.ssh_key.aws_name }}
    - user_data: |
        #cloud-config
        hostname: {{ HST }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
    - instance_type: {{ aws.infra_value(sls, "instance_type", HST, POD) }}
    - placement: {{ P_NET.subnets[SUBNET]["az"] }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{  P_LOC.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ aws.tags(name, POD, HST, POD) }}
    - require:
      - boto_ec2: {{ name_eni }}
{%- if id is none %}
{%- set id = salt.boto_ec2.get_id(region=LOC, name=name) %}
{%- endif %}


{% set ident = [HST, POD, "ebs-xvdf"] -%}
{% set name = ident|join("_") -%}
{% set name_ebs = name -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_id: {{ id }}
    - device: xvdf
    - size: {{ aws.infra_value(sls, "ebs_size", HST, POD) }}
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: {{ KMS_KEY_STORAGE }}
    - require:
      - boto_ec2: {{ name_instance }}


# If we have a valid instance ID, ensure both the xvda and xvdf volumes are
# tagged (without this stanza, the only volume tag is Name on xvdf).
#
# For filters information, see:
# https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.boto_ec2.html#salt.modules.boto_ec2.get_all_volumes
{%- if id and id is not none %}
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
          attachment.instance_id: {{ id }}
        tags:
          Name: {{ name }}
          cc:pod: {{ POD }}
{{- aws.infra_dict("aws", "tags", HST, POD, indent=10) }}
{%- endfor %}
{%- endif %}
