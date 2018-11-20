{% macro profile() -%}
- profile:
      key: {{ salt['environ.get']('AWS_ACCESS_KEY') }}
      keyid: {{ salt['environ.get']('AWS_KEY_ID') }}
      region: us-east-2
{%- endmacro %}
{% macro tags(name, pod) -%}
- tags:
        Name: {{ name }}
        Pod: {{ pod|title }}
{%- endmacro %}


### VPC

{% set title = "us-east-2" -%}
{% set pod = "core" -%}
{% set resource = "vpc" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
{% set name_vpc = name -%}
{{ name }}:
  boto_vpc.present:
    {{ profile() }}
    - name: {{ name }}
    - cidr_block: 10.22.0.0/16
    - dns_hostnames: True
    {{ tags(name, pod) }}


### Subnets

{% set title = "dmz" -%}
{% set pod = "core" -%}
{% set resource = "subnet" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
{% set name_dmz_subnet = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: us-east-2a
    - cidr_block: 10.22.10.0/24
    #- route_table_name: ## name_internet_route }}
    {{ tags(name, pod) }}
        Routing: Internet Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


{% set title = "private-one" -%}
{% set pod = "core" -%}
{% set resource = "subnet" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
{% set name_private_one_subnet = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: us-east-2b
    - cidr_block: 10.22.11.0/24
    {{ tags(name, pod) }}
        Routing: NAT Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


{% set title = "private-two" -%}
{% set pod = "core" -%}
{% set resource = "subnet" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
{% set name_private_two_subnet = name -%}
{{ name }}:
  boto_vpc.subnet_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    - availability_zone: us-east-2c
    - cidr_block: 10.22.12.0/24
    {{ tags(name, pod) }}
        Routing: NAT Gateway
    - require:
        - boto_vpc: {{ name_vpc }}


### Internet Gateway

{% set title = "us-east-2" -%}
{% set pod = "core" -%}
{% set resource = "internet-gateway" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
{% set name_internet_gateway = name -%}
{{ name }}:
  boto_vpc.internet_gateway_present:
    {{ profile() }}
    - name: {{ name }}
    - vpc_name: {{ name_vpc }}
    {{ tags(name, pod) }}
    - require:
        - boto_vpc: {{ name_vpc }}
        - boto_vpc: {{ name_dmz_subnet }}


{% set title = "internet" -%}
{% set pod = "core" -%}
{% set resource = "route-table" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
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
    {{ tags(name, pod) }}
    - require:
        - boto_vpc: {{ name_internet_gateway }}
        - boto_vpc: {{ name_dmz_subnet }}


### NAT Gateway

{% set title = "us-east-2" -%}
{% set pod = "core" -%}
{% set resource = "nat-gateway" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
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


{% set title = "nat" -%}
{% set pod = "core" -%}
{% set resource = "route-table" -%}
{% set name = title ~ "_" ~ pod ~ "_" ~ resource -%}
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
    {{ tags(name, pod) }}
    - require:
        - boto_vpc: {{ name_nat_gateway }}
        - boto_vpc: {{ name_private_one_subnet }}
        - boto_vpc: {{ name_private_two_subnet }}
