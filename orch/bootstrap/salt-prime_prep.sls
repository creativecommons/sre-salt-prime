{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set MID = pillar.tgt_mid -%}
{% set TEMP = "/srv/{}/orch/bootstrap/TEMP__{}".format(saltenv, MID) -%}
{% set IP = pillar.tgt_ip -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}
{#{% set TEMP = salt.temp.dir() %} -#}


{{ sls }} verify host is reachable:
  module.run:
    - name: network.ping
    - m_name: {{ P_POD.host_ips.pmwiki }}
    - host: {{ P_POD.host_ips.pmwiki }}
    - timeout: 15


{{ sls }} add ssh known host entry:
  ssh_known_hosts.present:
    - name: {{ IP }}
    - user: root
    - enc: ed25519
    - require:
      - module: {{ sls }} verify host is reachable


{{ sls }} backup previous minion key on prime :
  file.copy:
    - name: /etc/salt/pki/master/minions/{{ MID }}.BAK
    - source: /etc/salt/pki/master/minions/{{ MID }}


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
  file.copy:
    - name: /etc/salt/pki/master/minions/{{ MID }}
    - source: {{ TEMP }}/minion.pub


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
