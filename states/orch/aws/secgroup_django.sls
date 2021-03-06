# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}

{% set P_LOC = pillar.infra[LOC] -%}
{% set label = "infra:orch.aws.rds:secgroup_ec2:{}".format(HST__POD) -%}
{% set EC2_SECGROUP = salt.pillar.get(label, False) -%}


### Security Groups


{% if EC2_SECGROUP -%}
{% set ident = ["postgres-from-{}".format(HST), POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow PostgreSQL from {{ EC2_SECGROUP }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules:
      - ip_protocol: tcp
        from_port: 5432
        to_port: 5432
        source_group_name: {{ EC2_SECGROUP }}
    {{ aws.tags(name, POD, HST, POD) }}
{% else -%}
{% set ident = ["web-all-{}".format(HST), POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_secgroup_web = name -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow Web (HTTP/HTTPS) from anyone
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules:
      - ip_protocol: tcp
        from_port: 80
        to_port: 80
        cidr_ip:
          - 0.0.0.0/0
      - ip_protocol: tcp
        from_port: 443
        to_port: 443
        cidr_ip:
          - 0.0.0.0/0
    {{ aws.tags(name, POD, HST, POD) }}


{% set ident = ["postgres-from-{}".format(HST), POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set web_mid = "web-all-{}__{}__{}".format(HST, POD, LOC) -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow PostgreSQL from {{ name_secgroup_web }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules:
      - ip_protocol: tcp
        from_port: 5432
        to_port: 5432
        source_group_name: {{ name_secgroup_web }}
    {{ aws.tags(name, POD, HST, POD) }}
{% endif -%}
