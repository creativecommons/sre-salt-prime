infra:
  orch.aws.ec2_instance_web:
    ebs_size:
      default: 10
      chapters: 334
    instance_type:
      default: t3.small
      chapters: t3.medium
    secgroups:
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
      chapters:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_core_secgroup
