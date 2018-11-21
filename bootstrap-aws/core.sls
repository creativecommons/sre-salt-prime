# Parameters
{% set REGION = "us-east-2" -%}
{% set POD = "core" -%}
{% set VPC_CIDR = "10.22.10.0/16" -%}
{% set dmz = {"az": "us-east-2a", "cidr": "10.22.10.0/24"} -%}
{% set pr1 = {"az": "us-east-2b", "cidr": "10.22.11.0/24"} -%}
{% set pr2 = {"az": "us-east-2c", "cidr": "10.22.12.0/24"} -%}


# Variables
{% set AWS_ACCESS_KEY = salt['environ.get']('AWS_ACCESS_KEY') -%}
{% set AWS_KEY_ID = salt['environ.get']('AWS_KEY_ID')-%}
{% set SUBNET = {"dmz": dmz, "private-one": pr1, "private-two": pr2} -%}
# Macros
{% macro profile() -%}
- profile:
      key: {{ AWS_ACCESS_KEY }}
      keyid: {{ AWS_KEY_ID }}
      region: {{ REGION }}
{%- endmacro %}
{% macro tags(ident) -%}
{% set name = ident|join("_") -%}
{% set pod = ident[1]|title -%}
- tags:
        Name: {{ name }}
        Pod: {{ pod }}
{%- endmacro %}


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
{% set name_dmz_subnet = name -%}
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
{% set name_private_one_subnet = name -%}
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
{% set name_private_two_subnet = name -%}
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
        - boto_vpc: {{ name_dmz_subnet }}


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
      - {{ name_dmz_subnet }}
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_internet_gateway }}
        - boto_vpc: {{ name_dmz_subnet }}


### NAT Gateway

{% set ident = [REGION, POD, "nat-gateway"] -%}
{% set name = ident|join("_") -%}
{% set name_nat_gateway = name -%}
{{ name }}:
  boto_vpc.nat_gateway_present:
    {{ profile() }}
    - name: {{ name }}
    - subnet_name: {{ name_dmz_subnet }}
    - require:
        - boto_vpc: {{ name_dmz_subnet }}
        - boto_vpc: {{ name_private_one_subnet }}
        - boto_vpc: {{ name_private_two_subnet }}


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
        nat_gateway_subnet_name: {{ name_dmz_subnet }}
    - subnet_names:
      - {{ name_private_one_subnet }}
      - {{ name_private_two_subnet }}
    {{ tags(ident) }}
    - require:
        - boto_vpc: {{ name_nat_gateway }}
        - boto_vpc: {{ name_private_one_subnet }}
        - boto_vpc: {{ name_private_two_subnet }}
