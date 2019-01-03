{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}


{{ sls }} restore previous minion key on prime :
  cmd.run:
    - name: mv {{ MID }}.BAK {{ MID }}
    - cwd: /etc/salt/pki/master/minions/


{{ sls }} cleanup minion roster:
  file.managed:
    # See bootstrap.salt-prime_prep
    - name: /etc/salt/roster
    - contents:
      - "# salt-ssh roster emptied by {{ sls }}"
    - mode: '0444'


{{ sls }} remove ssh known host entry:
  cmd.run:
    - name: sudo ssh-keygen -R {{ IP }}
