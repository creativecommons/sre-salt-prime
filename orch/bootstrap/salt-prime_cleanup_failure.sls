{% set MID = pillar.tgt_mid -%}


{{ sls }} restore previous minion key on prime :
  cmd.run:
    - name: mv {{ MID }}.BAK {{ MID }}
    - cwd: /etc/salt/pki/master/minions/
