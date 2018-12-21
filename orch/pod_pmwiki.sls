{{ sls }} aws.common:
  salt.state:
    - tgt: {{ pillar.primary }}
    - sls: aws.common
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ pillar.tgt_pod }}
        tgt_reg: {{ pillar.tgt_reg }}


{{ sls }} aws.instance_pmwiki:
  salt.state:
    - tgt: {{ pillar.primary }}
    - sls: aws.instance_pmwiki
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ pillar.tgt_pod }}
        tgt_reg: {{ pillar.tgt_reg }}
