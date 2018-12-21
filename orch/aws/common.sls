{% import "aws/jinja2.yaml" as aws with context -%}
{% set POD = pillar.tgt_pod -%}
{% set REG = pillar.tgt_reg -%}

{% set P_AWS = pillar.infra.aws -%}
{% set P_REG = P_AWS[REG] -%}
{% set P_POD = P_REG[POD] -%}



### Security Groups


{% set ident = ["web-all", POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ REG }}
    - name: {{ name }}
    - description: Allow Web (HTTP/HTTPS) from anyone
    - vpc_name: {{ P_REG.vpc.name }}
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


### EC2 SSH Key


{% set ssh_key_comment = pillar.infra.provisioning.ssh_key.comment -%}
{% set ident = [ssh_key_comment|replace("_", "-"), POD, "ec2key"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.key_present:
    - region: {{ REG }}
    - name: {{ name }}
    - upload_public: '{{ pillar.infra.provisioning.ssh_key.pub }}'
