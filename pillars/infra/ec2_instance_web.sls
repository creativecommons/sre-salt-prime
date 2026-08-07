infra:
  orch.aws.ec2_instance_web:
    allocate_eip:
      # Default
      default: ABSENT
      # Specific (please maintain order)
      ccstatic: vpc
      chapters: vpc
      index: vpc
      licbuttons: vpc
      redirects: vpc
    ebs_size:
      # Default/
      default: 10
      # Specific (please maintain order)
      ccstatic: 214
      chapters: 334
      index: 214
      licbuttons: 214
    instance_type:
      # Default
      default: t3.micro
      # Specific (please maintain order)
      bastion: t3.nano
      chapters: t3.medium
      index__prod: r8a.medium
      index__stage: t3.small
    web_secgroups:
      # Default
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
      # Specific (please maintain order)
      chapters__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_prod_secgroup
      index__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-index_prod_secgroup
      index__stage:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-index_stage_secgroup
    web_subnet:
      # Default
      default: dmz
      # Specific (please maintain order)
