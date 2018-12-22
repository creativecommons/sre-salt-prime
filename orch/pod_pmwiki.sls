# Required command line pillar data:
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location


{{ sls }} aws.common:
  salt.state:
    - tgt: {{ pillar.primary }}
    - sls: aws.common
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ pillar.tgt_pod }}
        tgt_loc: {{ pillar.tgt_loc }}


{{ sls }} aws.instance_pmwiki:
  salt.state:
    - tgt: {{ pillar.primary }}
    - sls: aws.instance_pmwiki
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ pillar.tgt_pod }}
        tgt_loc: {{ pillar.tgt_loc }}
