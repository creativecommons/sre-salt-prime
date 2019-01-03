{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set MID = pillar.tgt_mid -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}
{#{% set TEMP = salt.temp.dir() %} -#}
{% set TEMP = "/srv/{}/orch/bootstrap/TEMP__{}".format(saltenv, MID) -%}


{{ sls }} backup previous minion key on prime :
  cmd.run:
    - name: cp -a {{ MID }} {{ MID }}.BAK
    - cwd: /etc/salt/pki/master/minions/


{{ sls }} ensure tmpdir exists:
  file.directory:
    - name: {{ TEMP }}
    - mode: '0770'


{{ sls }} create minion key pair:
  cmd.run:
    - name: salt-key --gen-keys=minion --no-color | tail -n1 | xargs
    - cwd: {{ TEMP }}
    - unless:
      - test -f {{ TEMP }}/minion.pem


{{ sls }} install minion key on prime :
  cmd.run:
    - name: cp -a minion.pub /etc/salt/pki/master/minions/{{ MID }}
    - cwd: {{ TEMP }}


{{ sls }} write minion roster:
  file.managed:
    # This is a dangerous and fragile way to do this, but I'm unable to get
    # salt.state (via salt-run state.orchestrat) to accept a custom roster
    # file :(
    #
    # Also see bootstrap.salt-prime_cleanup
    - name: /etc/salt/roster
    - contents:
      - "# Temporary salt-ssh roster file written by {{ sls }}"
      - "{{ MID }}:"
      - "  host: {{ P_POD.host_ips.pmwiki }}"
    - mode: '0444'
