# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set NET = pillar.tgt_net -%}

{% set CONF_SLS = pillar.conf_sls -%}

{% set P_SLS = pillar.infra[CONF_SLS] -%}
{% set P_LOC = pillar.infra[LOC] -%}
{% set P_NET = P_LOC[NET] -%}

{% set SUBNET = aws.infra_value(CONF_SLS, "web_subnet", HST, POD) -%}
{% set SUBNET_NAME = [SUBNET, NET, "subnet"]|join("_") -%}


{% set ident = [HST, POD, "eni"] -%}
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
{{- aws.infra_list(CONF_SLS, "web_secgroups", HST, POD) }}{{ "    " -}}
    - allocate_eip: {{ aws.infra_value(CONF_SLS, "allocate_eip", HST, POD) }}


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
    - instance_type: {{ aws.infra_value(CONF_SLS, "instance_type", HST, POD) }}
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
