# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% set MID = [HST, POD, LOC]|join("__") -%}
{% set TMP = "/srv/{}/states/orch/bootstrap/TEMP__{}".format(saltenv, MID) -%}

{% set P_LOC = pillar.infra[LOC] -%}

{% import_yaml "/srv/{}/pillars/infra/networks.yaml".format(saltenv) as nets %}
{% set NET = nets[POD__LOC] -%}
{% set P_NET = P_LOC[NET] -%}
{% set IP = P_NET["host_ips"][HST__POD] -%}

{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", ACCOUNT_ID,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}
# Phases:
# One: AWS Provisioning
# Two: Bootstrap via SSH (skipped if minion is already live)
# Three: Highstate


# Phase One: AWS Provisioning


{{ sls }} orch.aws.common:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.aws.common
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}


{{ sls }} orch.aws.secgroup_dispatch:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.aws.secgroup_dispatch
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_hst: {{ HST }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
    - require:
      - salt: {{ sls }} orch.aws.common


{{ sls }} orch.aws.ec2_instance_web:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.aws.ec2_instance_web
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_hst: {{ HST }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_net: {{ NET }}
        kms_key_storage: {{ KMS_KEY_STORAGE }}
    - require:
      - salt: {{ sls }} orch.aws.secgroup_dispatch


# Phase Two: Bootstrap via SSH
# (skipped if minion public key has been accepted and minion is already live)

{{ sls }} ssh bootstrap:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_mid: {{ MID }}
        tgt_tmp: {{ TMP }}
        tgt_ip: {{ IP }}
    - require:
      - salt: {{ sls }} orch.aws.ec2_instance_web


{#-
# Phase Three: Highstate


{{ sls }} verify minion:
  salt.function:
    - name: test.ping
    - tgt: {{ MID }}
    - retry:
        attempts: 6
        interval: 5
    - require:
      - salt: {{ sls }} orch.aws.ec2_instance_web
    - onlyif:
      - test -f /etc/salt/pki/master/minions/{{ MID }}


{{ sls }} minion highstate:
  salt.state:
    - tgt: {{ MID }}
    - saltenv: {{ saltenv }}
    - highstate: True
    - kwarg:
      saltenv: {{ saltenv }}
    - require:
      - salt: {{ sls }} verify minion
    - onlyif:
      - test -f /etc/salt/pki/master/minions/{{ MID }}
#}
