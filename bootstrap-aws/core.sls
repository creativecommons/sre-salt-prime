# Parameters
{% set REGION = "us-east-2" -%}
{% set POD = "core" -%}
{% set VPC_CIDR = "10.22.10.0/16" -%}
{% set dmz = {"az": "us-east-2a", "cidr": "10.22.10.0/24"} -%}
{% set pr1 = {"az": "us-east-2b", "cidr": "10.22.11.0/24"} -%}
{% set pr2 = {"az": "us-east-2c", "cidr": "10.22.12.0/24"} -%}
{% set DEPLOYSSH = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxkavD5saowkf1ZW/dzsLxJguYMKE8Y+YTKY2NHCNhGQSg9XPX3k+fgD3aFvgBnTL5qWPL52DA6TUnoCdcRbeNTBLceoLXbIpG27xkkQ6MFB+Fdk8jk0KprLs/SIsIeOZcukp47G5L7joKaqcflULFuF6DUeJxOmxPKMEPnYBLUDZuQ0Pe8QWgh98dx+n0TSlWkoSCLUnHuFPLjQeg9N/++kdd3KST5R4h651KoH8sZOOboE69HPHbf/JtpHQDC9JhRBVekScrrzGP4B0DA+ircTl5XBXWl4+IQkVQfisvbOtR8OWUmy9xzdKzGm6H4q5raLAUt1WHgzwgkMS3fy5K/hUaJnS1guvmLD0vD6CrsINZkGBsIUv2HqWQtddKO5o+RXLlVkt3NN44cwf4hqMgIaMbKs8fEAXcz/sGNHWvca3pO5oVY32G0ZBIzCGahuHNXtbuUSF4BbYkOr7QJnpg1h+dEzsdgoGMAnRc7ozFmO383GR6jyn4V7rf+SL5BfkhVe/XrwVY6NceQ8vZuHHppULyuLNNrK/W5dnYux65JgpiiPDu30Ng13JJHJ7UVbBgPps7aAA5noV03WqVlCOMqZkbkp0pbT1zQHYwvJ0ezK3BhEa1tDpKlPPeBEP013rAMEu0cV/VYXNsom6t/kDHKKRhhCuijxXE208y7zHVdQ== rsa_creativecommons_20181018" -%}

# Variables
{% set ACCESS_KEY = salt['environ.get']('AWS_ACCESS_KEY') -%}
{% set KEY_ID = salt['environ.get']('AWS_KEY_ID')-%}
{% set SUBNET = {"dmz": dmz, "private-one": pr1, "private-two": pr2} -%}
{% set PROFILE = {"region": REGION, "key": ACCESS_KEY, "keyid": KEY_ID} -%}
{% set ACCOUNT_ID = salt.boto_iam.get_account_id(**PROFILE) -%}
# Macros
{% macro profile() -%}
- profile:
      key: {{ ACCESS_KEY }}
      keyid: {{ KEY_ID }}
      region: {{ REGION }}
{%- endmacro %}
{% macro tags(ident) -%}
{% set name = ident|join("_") -%}
{% set pod = ident[1]|title -%}
- tags:
        Name: {{ name }}
        Pod: {{ pod }}
{%- endmacro %}

{# environment.filters['b64decode'] = base64.b64decode #}


### VPC


{% set ident = [REGION, POD, "vpc"] -%}
{% set name = ident|join("_") -%}
{% set name_vpc = name -%}
{{ name }}:
  boto_vpc.present:
    {{ profile() }}
    - name: {{ name }}
    - cidr_block: {{ VPC_CIDR }}
    - dns_hostnames: True
    {{ tags(ident) }}


### Subnets


{% set ident = ["dmz", POD, "subnet"] -%}
{% set name = ident|join("_") -%}
{% set name_subnet_dmz = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: {{ SUBNET[ident[0]]["az"] }}
    - cidr_block: {{ SUBNET[ident[0]]["cidr"] }}
    {{ tags(ident) }}
        Routing: Internet Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


{% set ident = ["private-one", POD, "subnet"] -%}
{% set name = ident|join("_") -%}
{% set name_subnet_private_one = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: {{ SUBNET[ident[0]]["az"] }}
    - cidr_block: {{ SUBNET[ident[0]]["cidr"] }}
    {{ tags(ident) }}
        Routing: NAT Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


{% set ident = ["private-two", POD, "subnet"] -%}
{% set name = ident|join("_") -%}
{% set name_subnet_private_two = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: {{ SUBNET[ident[0]]["az"] }}
    - cidr_block: {{ SUBNET[ident[0]]["cidr"] }}
    {{ tags(ident) }}
        Routing: NAT Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


### Internet Gateway


{% set ident = [REGION, POD, "internet-gateway"] -%}
{% set name = ident|join("_") -%}
{% set name_internet_gateway = name -%}
{{ name }}:
  boto_vpc.internet_gateway_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_vpc }}
        - boto_vpc: {{ name_subnet_dmz }}


{% set ident = ["internet", POD, "route-table"] -%}
{% set name = ident|join("_") -%}
{% set name_internet_route = name -%}
{{ name }}:
  boto_vpc.route_table_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - routes:
        - destination_cidr_block: 0.0.0.0/0
          internet_gateway_name: {{ name_internet_gateway }}
    - subnet_names:
        - {{ name_subnet_dmz }}
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_internet_gateway }}
        - boto_vpc: {{ name_subnet_dmz }}


### NAT Gateway


{% set ident = [REGION, POD, "nat-gateway"] -%}
{% set name = ident|join("_") -%}
{% set name_nat_gateway = name -%}
{{ name }}:
  boto_vpc.nat_gateway_present:
    {{ profile() }}
    - name: {{ name }}
    - subnet_name: {{ name_subnet_dmz }}
    - require:
        - boto_vpc: {{ name_internet_route }}
        - boto_vpc: {{ name_subnet_private_one }}
        - boto_vpc: {{ name_subnet_private_two }}


{% set ident = ["nat", POD, "route-table"] -%}
{% set name = ident|join("_") -%}
{% set name_nat_route = name -%}
{{ name }}:
  boto_vpc.route_table_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - routes:
        - destination_cidr_block: 0.0.0.0/0
          nat_gateway_subnet_name: {{ name_subnet_dmz }}
    - subnet_names:
        - {{ name_subnet_private_one }}
        - {{ name_subnet_private_two }}
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_nat_gateway }}
        - boto_vpc: {{ name_subnet_private_one }}
        - boto_vpc: {{ name_subnet_private_two }}


### KMS

{% set ident = ["storage", POD, "kmskey"] -%}
{% set name = ident|join("_") -%}
{% set name_kmskey_storage = name -%}
{{ name }}:
  boto_kms.key_present:
    {{ profile() }}
    - name: {{ name }}
    - description: Core Storage key
    - policy:
        Version: '2012-10-17'
        Id: key-policy-1
        Statement:
          - Effect: Allow
            Action: 'kms:*'
            Principal:
              AWS: 'arn:aws:iam::{{ ACCOUNT_ID }}:root'
            Resource: '*'
            Sid: Enable IAM User Permissions
    - key_rotation: True


### IAM Policies

{% set ident = ["ec2_perms", POD, "iam_policy"] -%}
{% set name = ident|join("_") -%}
{% set name_iam_policy_ec2_perms = name -%}
{{ name }}:
  boto_iam.policy_present:
    {{ profile() }}
    - name: {{ name }}
    - policy_document:
        # Note: Policy Document keys are title case
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - 'cloudwatch:DeleteDashboard'
              - 'cloudwatch:GetMetricStatistics'
              - 'cloudwatch:ListDashboards'
              - 'cloudwatch:ListMetrics'
              - 'cloudwatch:PutDashboard'
              - 'cloudwatch:PutMetricData'
              - 'ec2:DescribeTags'
            Resource: '*'
          - Effect: Allow
            Action:
              - 'kms:DescribeKey'
              - 'kms:GenerateDataKey*'
              - 'kms:Encrypt'
              - 'kms:ReEncrypt*'
              - 'kms:Decrypt'
              - 'kms:ListGrants'
              - 'kms:CreateGrant'
              - 'kms:RevokeGrant'
            Resource: |
              'arn:aws:kms::{{ ACCOUNT_ID }}:alias/{{ name_kmskey_storage }}'
    - require:
        - boto_kms: {{ name_kmskey_storage }}


### IAM Roles

{% set ident = ["ec2", POD, "iam_role"] -%}
{% set name = ident|join("_") -%}
{% set name_iam_role_ec2 = name -%}
{{ name }}:
  boto_iam_role.present:
    {{ profile() }}
    - name: {{ name }}
    - path: /
    - policy_document:
        # Note: Policy Document keys are title case
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action: 'sts:AssumeRole'
            Principal:
              Service: ec2.amazonaws.com
    - delete_policies: True
    - managed_policies:
        - {{ name_iam_policy_ec2_perms }}
    - create_instance_profile: True
    - require:
        - boto_iam: {{ name_iam_policy_ec2_perms }}


### Security Groups


{% set ident = ["pingtrace-all", POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_secgroup_pingtrace_all = name -%}
{{ name }}:
  boto_secgroup.present:
    {{ profile() }}
    - name: {{ name }}
    - description: Allow pings and UDP traceroute from anyone
    - vpc_name: {{ name_vpc }}
    - rules:
        - ip_protocol: icmp
          from_port: -1
          to_port: -1
          cidr_ip:
            - 0.0.0.0/0
        - ip_protocol: udp
          from_port: 33434
          to_port: 33534
          cidr_ip:
            - 0.0.0.0/0
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_vpc }}


{% set ident = ["ssh-all", POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_secgroup_ssh_all = name -%}
{{ name }}:
  boto_secgroup.present:
    {{ profile() }}
    - name: {{ name }}
    - description: Allow SSH from anyone
    - vpc_name: {{ name_vpc }}
    - rules:
        - ip_protocol: tcp
          from_port: 22
          to_port: 22
          cidr_ip:
            - 0.0.0.0/0
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_vpc }}


### Bastion EC2 Instance

{% set ident = ["deployssh", POD, "ec2key"] -%}
{% set name = ident|join("_") -%}
{% set name_ec2key_deployssh = name -%}
{{ name }}:
  boto_ec2.key_present:
    {{ profile() }}
    - name: {{ name }}
    - upload_public: '{{ DEPLOYSSH }}'


{% set ident = ["bastion-us-east-2", POD, "eni"] -%}
{% set name = ident|join("_") -%}
{% set name_eni_bastion_useast2 = name -%}
{{ name }}:
  boto_ec2.eni_present:
    {{ profile() }}
    - name: {{ name }}
    - description: Core Bastion ENI in us-east-2
    - subnet_name: {{ name_subnet_dmz }}
    - groups:
        - {{ name_secgroup_pingtrace_all }}
        - {{ name_secgroup_ssh_all }}
    - allocate_eip: vpc
    - require:
        - boto_secgroup: {{ name_secgroup_pingtrace_all }}
        - boto_secgroup: {{ name_secgroup_ssh_all }}
        - boto_vpc: {{ name_internet_route }}


{% set hostname = "bastion-us-east-2" -%}
{% set fqdn = (hostname, "creativecommons.org")|join(".") -%}
{% set ident = [hostname, POD, "ec2_instance"] -%}
{% set name = ident|join("_") -%}
{% set name_ec2_bastion_useast2 = name -%}
{{ name }}:
  boto_ec2.instance_present:
    {{ profile() }}
    - name: {{ name }}
    - instance_name: {{ fqdn }}
    - image_name: debian-stretch-hvm-x86_64-gp2-2018-11-10-63975
    - key_name: {{ name_ec2key_deployssh }}
    - user_data: {{ salt.hashutil.base64_b64encode(
        "#cloud-config" ~
        "\nhostname: " ~ hostname ~
        "\nfqdn: " ~ fqdn ~
        "\nmanage_etc_hosts: localhost\n") }}
    - instance_type: t2.nano
    - placement: {{ SUBNET["dmz"]["az"] }}
    - vpc_name: {{ name_vpc }}
    - monitoring_enabled: True
    - subnet_name: {{ name_subnet_dmz }}
    - instance_initiated_shutdown_behavior: stop
    - client_token: {{ name }}
    - security_group_names:
        - {{ name_secgroup_pingtrace_all }}
        - {{ name_secgroup_ssh_all }}
    - instance_profile_name: {{ name_iam_role_ec2 }}
    - network_interface_name: {{ name_eni_bastion_useast2 }}
    #- allocate_eip: True
    {{ tags(ident) }}
    - require:
        - boto_ec2: {{ name_ec2key_deployssh }}
        - boto_ec2: {{ name_eni_bastion_useast2 }}
        - boto_kms: {{ name_kmskey_storage }}
        - boto_vpc: {{ name_internet_route }}


{% set ident = ["bastion-home", POD, "ebs"] -%}
{% set name = ident|join("_") -%}
{% set name_ebs_bastion_home = name -%}
{{ name }}:
  boto_ec2.volume_present:
    {{ profile() }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_name: {{ name_ec2_bastion_useast2 }}
    - device: /dev/xvdf
    - size: 10
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: |
        'arn:aws:kms::{{ ACCOUNT_ID }}:alias/{{ name_kmskey_storage }}'
    - require:
        - boto_ec2: {{ name_ec2_bastion_useast2 }}
        - boto_kms: {{ name_kmskey_storage }}


