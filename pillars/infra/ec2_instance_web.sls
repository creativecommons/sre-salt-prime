{% set HST, POD, LOC = grains.id.split("__") -%}


infra:
  orch.aws.ec2_instance_web:
    allocate_eip:
      default: ABSENT
      chapters: vpc
    ebs_size:
      default: 10
      chapters: 334
    instance_type:
      default: t3.small
      chapters: t3.medium
    web_secgroups:
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_{{ POD }}_secgroup
      chapters:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_{{ POD }}_secgroup
    web_subnet:
      default: dmz
