# Required command line pillar data:
#   tgt_hst: Targeted Hostname and Wiki
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% set MID = [HST, POD, LOC]|join("__") -%}
{% set TMP = "/srv/{}/states/orch/bootstrap/TEMP__{}".format(saltenv, MID) -%}
{#{% set TMP = salt.temp.dir() %} -#}

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
# Two: Bootstrap (skipped if minion is already live)
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
    - retry:
        attempts: 3
        interval: 5


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
      - salt: {{ sls }} orch.aws.common
    - retry:
        attempts: 3
        interval: 5


# Phase Two: Bootstrap
# (skipped if minion public key has been accepted and minion is already live)


{{ sls }} minion public key accepted:
  salt.function:
    - name: cmd.run
    - tgt: {{ pillar.location.salt_prime_id }}
    - arg:
      - test -f /etc/salt/pki/master/minions/{{ MID }}
    - require:
      - salt: {{ sls }} orch.aws.ec2_instance_web


{{ sls }} minion already up:
  salt.function:
    - name: test.ping
    - tgt: {{ MID }}
    - retry:
        attempts: 3
        interval: 5
    - require:
      - salt: {{ sls }} minion public key accepted
    - onlyif:
      - test -f /etc/salt/pki/master/minions/{{ MID }}


{{ sls }} salt-prime minion bootstrap prep:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.prime_prep
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_mid: {{ MID }}
        tgt_tmp: {{ TMP }}
        tgt_ip: {{ IP }}
    # NOTE: onfail_any requires failhard: False
    #       See: https://github.com/saltstack/salt/issues/20496
    - onfail_any:
      - salt: {{ sls }} minion public key accepted
      - salt: {{ sls }} minion already up


{{ sls }} bootstrap minion:
  salt.state:
    - tgt: {{ MID }}
    - sls: orch.bootstrap.minion
    - saltenv: {{ saltenv }}
    - ssh: True
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
    - require:
      - salt: {{ sls }} salt-prime minion bootstrap prep
    - onlyif:
      - test -d {{ TMP }}


{{ sls }} salt-prime minion bootstrap cleanup failure:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.prime_cleanup_failure
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
    # NOTE: onfail_any requires failhard: False
    #       See: https://github.com/saltstack/salt/issues/20496
    - onfail_any:
      - salt: {{ sls }} salt-prime minion bootstrap prep
      - salt: {{ sls }} bootstrap minion


{{ sls }} salt-prime minion bootstrap cleanup success:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.prime_cleanup_success
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
        tgt_ip: {{ IP }}
        tgt_tmp: {{ TMP }}
    - onlyif:
      - test -d {{ TMP }}


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


{{ sls }} complete minion configuration:
  salt.state:
    - tgt: {{ MID }}
    - saltenv: {{ saltenv }}
    - highstate: True
    - require:
      - salt: {{ sls }} verify minion
