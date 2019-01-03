# Required command line pillar data:
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}
{% set MINION_ID = ["pmwiki", POD, LOC]|join("__") -%}


{{ sls }} aws.common:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: aws.common
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
    - retry:
        attempts: 3
        interval: 5


{{ sls }} aws.instance_pmwiki:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: aws.instance_pmwiki
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        aws_account_id: {{ ACCOUNT_ID }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
    - retry:
        attempts: 3
        interval: 5


{{ sls }} salt-prime minion bootstrap prep:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: bootstrap.salt-prime_prep
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_mid: {{ MINION_ID }}


{{ sls }} verify minion is reachable:
  salt.function:
    - name: cmd.run
    - tgt: {{ pillar.location.salt_prime_id }}
    - arg:
      - ping -qc1 {{ P_POD.host_ips.pmwiki }}
    - retry:
        attempts: 12
        interval: 5


{{ sls }} accept minion ssh host key:
  salt.function:
    - name: cmd.run
    - tgt: {{ pillar.location.salt_prime_id }}
    - arg:
      - >-
        ssh-keyscan -t ed25519 -T 3 -H {{ P_POD.host_ips.pmwiki }} >>
        /root/.ssh/known_hosts


{{ sls }} bootstrap minion:
  salt.state:
    - tgt: {{ MINION_ID }}
    - sls: bootstrap.minion
    - saltenv: {{ saltenv }}
    - ssh: True
    - kwarg:
      pillar:
        tgt_mid: {{ MINION_ID }}


{{ sls }} salt-prime minion bootstrap cleanup failure:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: bootstrap.salt-prime_cleanup_failure
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MINION_ID }}
        tgt_ip: {{ P_POD.host_ips.pmwiki }}
    # onfail and onfail_any do NOT work here :(
    # TO DO: create test case and file issue
    - onfail_any:
      - salt: {{ sls }} salt-prime minion bootstrap prep
      - salt: {{ sls }} bootstrap minion


{{ sls }} salt-prime minion bootstrap cleanup success:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: bootstrap.salt-prime_cleanup_success
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MINION_ID }}
        tgt_ip: {{ P_POD.host_ips.pmwiki }}


# Following fails sometimes. Add sleep between salt-ssh and highstate?


{{ sls }} complete minion configuration:
  salt.state:
    - tgt: {{ MINION_ID }}
    - saltenv: {{ saltenv }}
    - highstate: True
