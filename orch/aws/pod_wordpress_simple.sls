{% FAIL__work_in_progress__do_not_use %}
{#

WORK IN PROGRESS - DO NOT USE

Need to determine CDN/DNS configa before moving forward.

sudo salt-run --state-output=full_id --state-verbose=True --log-level=debug --log-file-level=warning state.orchestrate aws.pod_wordpress_simple pillar='{"tgt_pod":"gnwp", "tgt_loc":"us-east-2"}' saltenv=timidrobot test=True

#}
{% import "aws/jinja2.sls" as aws with context -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}


# The region must NOT be omitted from the KMS Key ID
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", pillar.aws_account_id,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}


# Security Groups


{% set ident = ["mysql-private", POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_secgroup.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: Allow MySQL from private subnets
    - vpc_name: {{ P_LOC.vpc.name }}
    - rules: {# (correct jinja whitespace) -#}
{% for subnet, data in P_POD.subnets.items() -%}
{% if subnet.startswith("private-") %}
      - ip_protocol: tcp
        from_port: 3306
        to_port: 3306
        cidr_ip:
          - {{ data.cidr -}}
{% endif %}
{%- endfor %}
    {{ aws.tags(ident) }}


# Subnets


{% for subnet, data in P_POD.subnets.items() -%}
{% set ident = [subnet, POD, "subnet"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_vpc.subnet_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - availability_zone: {{ data.az }}
    - cidr_block: {{ data.cidr }}
    - route_table_name: {{ data.route_table }}
    {{ aws.tags(ident) }}
        Routing: {{ data.tag_routing }}

{% endfor %}


# WordPress Host


{% set hostname = "gnwordpress" -%}


{% set ident = [hostname, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{% set subnet_name = ["private-one", POD, "subnet"]|join("_") -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ POD }} WordPress ENI in {{ LOC }}
    - subnet_name: {{ subnet_name }}
    - private_ip_address: {{ P_LOC.hosts_ips.wordpress }}
    - groups:
        - pingtrace-all_core_secgroup
        - ssh-from-bastion_core_secgroup
# (?) should this only allow web traffic from CDN?
#     or from VPC (to allow testing)?
        - web-all_core_secgroup
    - require:
        - boto_vpc: {{ subnet_name }}


{% set fqdn = (hostname, "creativecommons.org")|join(".") -%}
{% set ident = [hostname, POD, "ec2_instance"] -%}
{% set name = ident|join("_") -%}
{% set name_instance = name -%}
{{ name }}:
  boto_ec2.instance_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - instance_name: {{ name }}
    - image_name: {{ P_LOC.debian_ami_name }}
    - key_name: {{ pillar.infra.provisioning.ssh_key.aws_name }}
    - user_data: |
        #cloud-config
        hostname: {{ hostname }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
        # This adds a mountpoint with "nofail". The volume won't mount properly
        # until it is formatted.
        #
        # sudo mkfs.ext4 -L gnwordpress-var-www /dev/nvme1n1
        mounts:
          - [ /dev/nvme1n1, /var/www, ext4 ]
    - instance_type: t3.small
    - placement: {{ P_POD.subnets.private-one.az }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{ P_LOC.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ tags(ident) }}
    - require:
        - boto_ec2: {{ name_eni }}


{% set ident = ["gnwordpress-var-www", POD, "ebs"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_name: {{ name_instance }}
    - device: xvdf
    - size: 10
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: {{ KMS_KEY_STORAGE }}
    - require:
        - boto_ec2: {{ name_instance }}
