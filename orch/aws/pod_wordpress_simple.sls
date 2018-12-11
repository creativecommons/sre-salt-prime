# Invoke with:
# POD=podname; REG=region; sudo salt-call --id=xxx__${POD}__${REG} \
#   --local state.apply aws.pod_wordpress_simple test=True
{% import "aws/jinja2.yaml" as aws with context -%}
{% set VPC_NAME = pillar["infra"]["vpc"]["name"] -%}


# Security Groups


{% set ident = ["mysql-private", pillar["pod"], "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ pillar["infra"]["region"] }}
    - name: {{ name }}
    - description: Allow MySQL from private subnets
    - vpc_name: {{ VPC_NAME }}
    - rules: {# (correct jinja whitespace) -#}
{% for subnet, data in pillar["infra"]["subnets"].items() -%}
{% if subnet.startswith("private-") %}
      - ip_protocol: tcp
        from_port: 3306
        to_port: 3306
        cidr_ip:
          - {{ data["cidr"] -}}
{% endif %}
{%- endfor %}
    {{ aws.tags(ident) }}


# Subnets


{% for subnet, data in pillar["infra"]["subnets"].items() -%}
{% set ident = [subnet, pillar["pod"], "subnet"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_vpc.subnet_present:
    - region: {{ pillar["infra"]["region"] }}
    - name: {{ name }}
    - vpc_name: {{ VPC_NAME }}
    - availability_zone: {{ data["az"] }}
    - cidr_block: {{ data["cidr"] }}
    - route_table_name: {{ data["route_table"] }}
    {{ aws.tags(ident) }}
        Routing: {{ data["tag_routing"] }}

{% endfor %}


# WordPress Host


# Whoops this is not publically accessible. Need to determine CDN/DNS issues
# before moving forward.

{#
{% set ident = ["wordpress", pillar["pod"], "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set subnet_name = ["private-one", pillar["pod"], "subnet"]|join("_") -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ pillar["infra"]["region"] }}
    - name: {{ name }}
    - description: >-
        {{ pillar["pod"] }} WordPress ENI in {{ pillar["infra"]["region"] }}
    - subnet_name: {{ subnet_name }}
    - private_ip_address: {{ pillar["infra"]["hosts"]["wordpress"]["ip"] }}
    - groups:
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
    - require:
        - boto_vpc: {{ subnet_name }}
#}


{#
{% set hostname = "gn-wordpress" -%}
{% set fqdn = (hostname, "creativecommons.org")|join(".") -%}
{% set ident = [hostname, POD, "ec2_instance"] -%}
{% set name = ident|join("_") -%}
{% set name_ec2_salt_prime = name -%}
{{ name }}:
  boto_ec2.instance_present:
    {{ profile() }}
    - name: {{ name }}
    - instance_name: {{ fqdn }}
    - image_name: {{ IMAGE_NAME }}
    - key_name: {{ name_ec2key_deployssh }}
    - user_data: |
        #cloud-config
        hostname: {{ hostname }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
        # This adds a mountpoint with "nofail". The volume won't mount properly
        # until it is formatted.
        #
        # sudo mkfs.ext4 -L salt-prime-srv /dev/nvme1n1
        mounts:
          - [ /dev/nvme1n1, /srv, ext4 ]
    - instance_type: t3.small
    - placement: {{ SUBNET["private-one"]["az"] }}
    - vpc_name: {{ name_vpc }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - client_token: {{ name }}v8
    - instance_profile_name: {{ name_iam_role_ec2_salt_prime }}
    - network_interface_name: {{ name_eni_salt_prime }}
    {{ tags(ident) }}
    - require:
        - boto_ec2: {{ name_ec2key_deployssh }}
        - boto_ec2: {{ name_eni_salt_prime }}
        - boto_iam_role: {{ name_iam_role_ec2_salt_prime }}

#}


# RDS


# TODO
