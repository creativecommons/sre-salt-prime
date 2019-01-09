# Required command line pillar data:
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set HOST = "pmwiki" -%}
{% set MID = [HOST, POD, LOC]|join("__") -%}
{% set TEMP = "/srv/{}/orch/bootstrap/TEMP__{}".format(saltenv, MID) -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}


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


{{ sls }} orch.aws.instance_pmwiki:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.aws.instance_pmwiki
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        aws_account_id: {{ ACCOUNT_ID }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_host: {{ HOST }}
    - require:
      - salt: {{ sls }} orch.aws.common
    - retry:
        attempts: 3
        interval: 5


# Phase Two: Bootstrap (skipped if minion is already live)


{{ sls }} minion already up:
  salt.function:
    - name: test.ping
    - tgt: {{ MID }}
    - retry:
        attempts: 3
        interval: 5
    - require:
      - salt: {{ sls }} orch.aws.instance_pmwiki


{{ sls }} salt-prime minion bootstrap prep:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.salt-prime_prep
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_mid: {{ MID }}
        tgt_ip: {{ P_POD.host_ips.pmwiki }}
    - onfail:
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
      - test -d {{ TEMP }}


{{ sls }} salt-prime minion bootstrap cleanup failure:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.salt-prime_cleanup_failure
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
    - sls: orch.bootstrap.salt-prime_cleanup_success
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
        tgt_ip: {{ P_POD.host_ips.pmwiki }}
    - onlyif:
      - test -d {{ TEMP }}


# Phase Three: Highstate


{{ sls }} verify minion:
  salt.function:
    - name: test.ping
    - tgt: {{ MID }}
    - retry:
        attempts: 6
        interval: 5
    - require:
      - salt: {{ sls }} orch.aws.instance_pmwiki 


{{ sls }} complete minion configuration:
  salt.state:
    - tgt: {{ MID }}
    - saltenv: {{ saltenv }}
    - highstate: True
    - require:
      - salt: {{ sls }} verify minion
