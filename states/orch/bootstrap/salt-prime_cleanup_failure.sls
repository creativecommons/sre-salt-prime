{% set MID = pillar.tgt_mid -%}


{{ sls }} restore previous minion key on prime :
  file.rename:
    - name: /etc/salt/pki/master/minions/{{ MID }}
    - source: /etc/salt/pki/master/minions/{{ MID }}.BAK
    - force: True
