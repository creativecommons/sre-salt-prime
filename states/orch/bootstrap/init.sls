# Bootstrap mininon using salt-ssh (unless the minion is already up and
# answering)
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}
{% set TMP = pillar.tgt_tmp -%}


{{ sls }} minion public key accepted:
  salt.function:
    - name: cmd.run
    - tgt: {{ pillar.location.salt_prime_id }}
    - arg:
      - test -f /etc/salt/pki/master/minions/{{ MID }}


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
    - concurrent: True
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


# https://github.com/saltstack/salt/issues/61535
{{ sls }} install dependency python3-distro:
  salt.function:
    - name: cmd.run
    - arg:
      - ssh -i /root/.ssh/saltstack_rsa_provisioning_20181221 admin@{{ IP }} sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq python3-distro
    - tgt: {{ pillar.location.salt_prime_id }}
    - saltenv: {{ saltenv }}
    - require:
      - salt: {{ sls }} salt-prime minion bootstrap prep
    - onlyif:
      - test -d {{ TMP }}


{{ sls }} install salt on minion:
  salt.state:
    - tgt: {{ MID }}
    - sls: salt
    - saltenv: {{ saltenv }}
    - ssh: True
    - require:
      - salt: {{ sls }} install dependency python3-distro
    - onlyif:
      - test -d {{ TMP }}


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
      - salt: {{ sls }} install salt on minion
    - onlyif:
      - test -d {{ TMP }}


{{ sls }} salt-prime minion bootstrap cleanup failure:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.prime_cleanup_failure
    - saltenv: {{ saltenv }}
    - concurrent: True
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
    # NOTE: onfail_any requires failhard: False
    #       See: https://github.com/saltstack/salt/issues/20496
    - onfail_any:
      - salt: {{ sls }} install salt on minion
      - salt: {{ sls }} salt-prime minion bootstrap prep
      - salt: {{ sls }} bootstrap minion


{{ sls }} salt-prime minion bootstrap cleanup success:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - sls: orch.bootstrap.prime_cleanup_success
    - saltenv: {{ saltenv }}
    - concurrent: True
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
        tgt_ip: {{ IP }}
        tgt_tmp: {{ TMP }}
    - require_any:
      - salt: {{ sls }} minion already up
      - salt: {{ sls }} bootstrap minion
    - onlyif:
      - test -d {{ TMP }}
