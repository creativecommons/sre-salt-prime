{% set MID = pillar.tgt_mid -%}
{% set IP = pillar.tgt_ip -%}


{{ sls }} delete previous minion key backup on prime :
  cmd.run:
    - name: rm -f {{ MID }}.BAK
    - cwd: /etc/salt/pki/master/minions/


{{ sls }} cleanup tmpdir:
  file.absent:
    - name: /srv/{{ saltenv }}/orch/bootstrap/TEMP__{{ MID }}


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
