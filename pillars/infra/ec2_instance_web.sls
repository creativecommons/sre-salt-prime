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
        - pingtrace-all_{{ POD }}_secgroup
        - ssh-from-salt-prime_{{ POD }}_secgroup
        - ssh-from-bastion_{{ POD }}_secgroup
        - web-all_{{ POD }}_secgroup
      chapters:
        - pingtrace-all_{{ POD }}_secgroup
        - ssh-from-salt-prime_{{ POD }}_secgroup
        - ssh-from-bastion_{{ POD }}_secgroup
        - web-all-chapters_{{ POD }}_secgroup
    web_subnet:
      default: dmz
