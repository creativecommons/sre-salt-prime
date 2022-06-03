infra:
  orch.aws.ec2_instance_web:
    allocate_eip:
      # Default
      default: ABSENT
      # Specific (please maintain order)
      biztool: vpc
      ccorg: vpc
      cert: vpc
      chapters: vpc
      dispatch: vpc
      licbuttons: vpc
      opencovid: vpc
      openglam: vpc
      podcast: vpc
      redirects: vpc
      summit: vpc
    ebs_size:
      # Default
      default: 10
      # Specific (please maintain order)
      ccengine: 214
      ccorg: 214
      cert: 214
      chapters: 334
      dispatch: 214
      licbuttons: 214
      opencovid: 214
      openglam: 214
      summit: 214
    instance_type:
      # Default
      default: t3.micro
      # Specific (please maintain order)
      bastion: t3.nano
      ccengine: t3.small
      ccorg: t3.small
      cert: t3.small
      chapters: t3.medium
      opencovid: t3.small
      wikijs: t3.small
    web_secgroups:
      # Default
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
      # Specific (please maintain order)
      biztool__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-biztool_prod_secgroup
      ccengine__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-from-dispatch_prod_secgroup
      ccorg__stage:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-ccorg_stage_secgroup
      cert__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-cert_prod_secgroup
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
      dispatch__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-dispatch_prod_secgroup
      misc__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-from-dispatch_prod_secgroup
      opencovid__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-opencovid_prod_secgroup
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
      summit__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-summit_prod_secgroup
    web_subnet:
      # Default
      default: dmz
      # Specific (please maintain order)
      ccengine: private-one
      misc: private-one
