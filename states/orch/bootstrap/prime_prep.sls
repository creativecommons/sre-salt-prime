{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}
{% set TMP = pillar.tgt_tmp -%}

{% set P_LOC = pillar.infra[LOC] -%}
{% set P_POD = P_LOC[POD] -%}


{{ sls }} verify host is reachable:
  module.run:
    - name: network.ping
    - m_name: {{ IP }}
    - host: {{ IP }}
    - timeout: 15


{{ sls }} add ssh known host entry:
  ssh_known_hosts.present:
    - name: {{ IP }}
    - user: root
    - require:
      - module: {{ sls }} verify host is reachable


{{ sls }} backup previous minion key on prime:
  file.copy:
    - name: /etc/salt/pki/master/minions/{{ MID }}.BAK
    - source: /etc/salt/pki/master/minions/{{ MID }}
    - onlyif:
      - test -f /etc/salt/pki/master/minions/{{ MID }}


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


{{ sls }} digest of minion pub in TEMP:
  module.run:
    - name: hashutil.digest_file
    - kwarg:
      infile: {{ TMP }}/minion.pub
    - require:
      - file: {{ sls }} ensure tmpdir exists


{{ sls }} install minion pub on prime:
  file.copy:
    - name: /etc/salt/pki/master/minions/{{ MID }}
    - source: {{ TMP }}/minion.pub
    - force: True
    - require:
      - module: {{ sls }} digest of minion pub in TEMP


{{ sls }} digest of minion pub on salt-prime:
  module.run:
    - name: hashutil.digest_file
    - kwarg:
      infile: /etc/salt/pki/master/minions/{{ MID }}
    - require:
      - file: {{ sls }} install minion pub on prime


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
    - require:
      - ssh_known_hosts: {{ sls }} add ssh known host entry
