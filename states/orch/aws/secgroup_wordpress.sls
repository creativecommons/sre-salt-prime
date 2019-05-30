# Required command line pillar data:
#   tgt_hst: Targeted Hostname and Wiki
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_LOC = pillar.infra[LOC] -%}


### Security Groups


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


{% set ident = ["mysql-from-{}".format(HST), POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set web_mid = "web-all-{}__{}__{}".format(HST, POD, LOC) -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow MySQL from {{ name_secgroup_web }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules:
      - ip_protocol: tcp
        from_port: 3306
        to_port: 3306
        source_group_name: {{ name_secgroup_web }}
    {{ aws.tags(name, POD, HST, POD) }}
