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
{% set subnet_key = ("infra:{}:subnet:{}".format(sls, HST)) -%}
{% set subnet_default = P_SLS["subnet"]["default"] -%}
{% set SUBNET = salt["pillar.get"](subnet_key, subnet_default) %}
{% set SUBNET_NAME = [SUBNET, POD, "subnet"]|join("_") -%}


### EC2 Instance


{% set ident = [HST, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ POD }} {{ HST }} ENI in {{ LOC }}
    - subnet_name: {{ SUBNET_NAME }}
    - private_ip_address: {{ P_POD["host_ips"][HST] }}
    - groups:
{{ aws.infra_list(sls, "secgroups", HST) }}


{% set fqdn = (HST, "creativecommons.org")|join(".") -%}
{% set ident = [HST, POD, LOC] -%}
{% set name = ident|join("_") -%}
{% set name_instance = name -%}
{{ name }}:
  boto_ec2.instance_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - instance_name: {{ name }}
    - image_name: {{ P_LOC.debian_ami_name }}
    - key_name: {{ pillar.infra.provisioning.ssh_key.aws_name }}
    - user_data: |
        #cloud-config
        hostname: {{ HST }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
    - instance_type: {{ aws.infra_value(sls, "instance_type", HST) }}
    - placement: {{ P_POD.subnets[SUBNET]["az"] }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{  P_LOC.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ aws.tags(ident) }}
    - require:
      - boto_ec2: {{ name_eni }}


{% set ident = ["{}-xvdf".format(HST), POD, "ebs"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_name: {{ name_instance }}
    - device: xvdf
    - size: {{ aws.infra_value(sls, "ebs_size", HST) }}
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: {{ KMS_KEY_STORAGE }}
    - require:
      - boto_ec2: {{ name_instance }}
