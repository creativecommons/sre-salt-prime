infra:
  orch.aws.ec2_instance_web:
    allocate_eip:
      default: ABSENT
      biztool: vpc
      chapters: vpc
      openglam: vpc
      podcast: vpc
      redirects: vpc
      sotc: vpc
    ebs_size:
      default: 10
      chapters: 334
      sotc: 214
      openglam: 214
    instance_type:
      default: t3.micro
      bastion: t3.nano
      chapters: t3.medium
      discourse: t3.small
      sotc: t3.medium
      wikijs: t3.small
    web_secgroups:
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
      biztool__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-biztool_prod_secgroup
      chapters__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_prod_secgroup
      chapters__stage:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_stage_secgroup
      openglam__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-openglam_prod_secgroup
      podcast__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-podcast_prod_secgroup
      sotc__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-sotc_prod_secgroup
    web_subnet:
      default: dmz
