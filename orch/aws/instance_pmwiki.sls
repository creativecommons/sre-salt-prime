{% import "aws/jinja2.yaml" as aws with context -%}
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{% set POD = pillar.tgt_pod -%}
{% set REG = pillar.tgt_reg -%}

{% set P_AWS = pillar.infra.aws -%}
{% set P_REG = P_AWS[REG] -%}
{% set P_POD = P_REG[POD] -%}

# The region must NOT be omitted from the KMS Key ID
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", ACCOUNT_ID, ":alias/",
                          P_REG.kms_key_id_storage]|join("") -%}


### EC2 Instance: PmWiki


{% set hostname = "pmwiki" -%}


{% set ident = [hostname, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{% set subnet_name = ["dmz", POD, "subnet"]|join("_") -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ REG }}
    - name: {{ name }}
    - description: {{ POD }} PmWiki ENI in {{ REG }}
    - subnet_name: {{ subnet_name }}
    - private_ip_address: {{ P_POD["host_ips"][hostname] }}
    - groups:
        - pingtrace-all_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup


{% set fqdn = (hostname, "creativecommons.org")|join(".") -%}
{% set ident = [hostname, POD, REG] -%}
{% set name = ident|join("_") -%}
{% set name_instance = name -%}
{{ name }}:
  boto_ec2.instance_present:
    - region: {{ REG }}
    - name: {{ name }}
    - instance_name: {{ name }}
    - image_name: {{ P_REG.debian_ami_name }}
    - key_name: {{ pillar.infra.provisioning.ssh_key.aws_name }}
    - user_data: |
        #cloud-config
        hostname: {{ hostname }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
        # This adds a mountpoint with "nofail". The volume won't mount properly
        # until it is formatted.
        #
        # sudo mkfs.ext4 -L salt-prime-srv /dev/nvme1n1
        mounts:
          - [ /dev/nvme1n1, /var/www, ext4 ]
    - instance_type: t3.small
    - placement: {{ P_POD.subnets.dmz.az }}
    - vpc_name: {{ P_REG.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{  P_REG.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ aws.tags(ident) }}
    - require:
        - boto_ec2: {{ name_eni }}


{% set ident = ["pmwiki-var-www", POD, "ebs"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ REG }}
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
