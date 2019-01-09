{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}
{% set TMP = pillar.tgt_tmp -%}

{% set P_LOC = pillar["infra"][LOC] -%}
{% set P_POD = P_LOC[POD] -%}


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
    - name: {{ TMP }}
    - mode: '0770'


{{ sls }} create minion key pair:
  cmd.run:
    - name: salt-key --gen-keys=minion --no-color | tail -n1 | xargs
    - cwd: {{ TMP }}
    - require:
      - file: {{ sls }} ensure tmpdir exists
    - unless:
      - test -f {{ TMP }}/minion.pem


{{ sls }} install minion key on prime :
  file.copy:
    - name: /etc/salt/pki/master/minions/{{ MID }}
    - source: {{ TMP }}/minion.pub


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
      - "  host: {{ IP }}"
    - mode: '0444'
