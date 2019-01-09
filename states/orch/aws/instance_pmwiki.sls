{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HOST = pillar.tgt_host -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}

# The region must NOT be omitted from the KMS Key ID
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", pillar.aws_account_id,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}


### EC2 Instance


{% set ident = [HOST, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{% set subnet_name = ["dmz", POD, "subnet"]|join("_") -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ POD }} PmWiki ENI in {{ LOC }}
    - subnet_name: {{ subnet_name }}
    - private_ip_address: {{ P_POD["host_ips"][HOST] }}
    - groups:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup


{% set fqdn = (HOST, "creativecommons.org")|join(".") -%}
{% set ident = [HOST, POD, LOC] -%}
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
        hostname: {{ HOST }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
        # This adds a mountpoint with "nofail". The volume won't mount properly
        # until it is formatted.
        #
        # sudo mkfs.ext4 -L pmwiki-var-www /dev/nvme1n1
        mounts:
          - [ /dev/nvme1n1, /var/www, ext4 ]
    - instance_type: t3.small
    - placement: {{ P_POD.subnets.dmz.az }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{  P_LOC.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ aws.tags(ident) }}
    - require:
        - boto_ec2: {{ name_eni }}


{% set ident = ["pmwiki-var-www", POD, "ebs"] -%}
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
