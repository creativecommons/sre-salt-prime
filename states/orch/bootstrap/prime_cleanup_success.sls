{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}
{% set TMP = pillar.tgt_tmp -%}


{{ sls }} delete previous minion key backup on prime :
  file.absent:
    - name: /etc/salt/pki/master/minions/{{ MID }}.BAK


{{ sls }} cleanup tmpdir:
  file.absent:
    - name: {{ TMP }}


{{ sls }} cleanup minion roster:
  file.managed:
    # See bootstrap.salt-prime_prep
    - name: /etc/salt/roster
    - contents:
      - "# salt-ssh roster emptied by {{ sls }}"
    - mode: '0444'


{{ sls }} remove ssh known host entry:
  ssh_known_hosts.absent:
    - name: {{ IP }}
    - user: root
