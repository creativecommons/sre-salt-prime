# This file does not reproduce the subnets in bootstrap-aws/core.sls
#
# Invoke with:
# POD=podname; REG=region; sudo salt-call --id=xxx__${POD:-core}__${REG} \
#   --local state.apply aws.security_groups test=True
{% import "aws/jinja2.yaml" as aws with context -%}
{% set VPC_NAME = pillar["infra"]["vpc"]["name"] -%}


{% set ident = ["web-all", "core", "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ pillar["infra"]["region"] }}
    - name: {{ name }}
    - description: Allow Web (HTTP/HTTPS) from anyone
    - vpc_name: {{ VPC_NAME }}
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
    {{ aws.tags(ident) }}
