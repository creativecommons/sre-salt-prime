{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_LOC = pillar.infra[LOC] -%}


### Security Groups


{% set ident = ["web-all", "core", "secgroup"] -%}
{% set name = ident|join("_") -%}
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
    {{ aws.tags(name, "core", "core", "secgroup") }}


{% set ident = ["ssh-from-salt-prime", "core", "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow SSH from salt-prime
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules:
      - ip_protocol: tcp
        from_port: 22
        to_port: 22
        source_group_name: salt-vpc_core_secgroup
    {{ aws.tags(name, "core", "core", "secgroup") }}


### EC2 SSH Key


{% set ssh_key_comment = pillar.infra.provisioning.ssh_key.comment -%}
{% set ident = [ssh_key_comment|replace("_", "-"), POD, "ec2key"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.key_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - upload_public: '{{ pillar.infra.provisioning.ssh_key.pub }}'
