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
    - sls: prime_prep
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
    - sls: minion
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
    - sls: prime_cleanup_failure
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
    - sls: prime_cleanup_success
    - saltenv: {{ saltenv }}
    - kwarg:
      pillar:
        tgt_mid: {{ MID }}
        tgt_ip: {{ IP }}
        tgt_tmp: {{ TMP }}
    - onlyif:
      - test -d {{ TMP }}
