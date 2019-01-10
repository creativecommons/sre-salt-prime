{% set MID = pillar.tgt_mid -%}


include:
  - salt


{{ sls }} set minion id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents:
      - {{ MID }}
    - mode: '0444'


{{ sls }} install public key:
  file.managed:
    - name: /etc/salt/pki/minion/minion.pub
    - source: salt://orch/bootstrap/TEMP__{{ MID }}/minion.pub
    - mode: '0444'
    - require:
      - cmd: salt.minion upgrade minion


{{ sls }} digest of minion pub on minion:
  module.run:
    - name: hashutil.digest_file
    - kwarg:
      infile: /etc/salt/pki/minion/minion.pub


{{ sls }} install private key:
  file.managed:
    - name: /etc/salt/pki/minion/minion.pem
    - source: salt://orch/bootstrap/TEMP__{{ MID }}/minion.pem
    - mode: '0400'
    - require:
      - cmd: salt.minion upgrade minion


{{ sls }} restart minion:
  cmd.run:
    - name: nohup /usr/local/sbin/restart_minion.sh &
    - onchanges:
      - file: {{ sls }} set minion id
      - file: {{ sls }} install public key
      - file: {{ sls }} install private key
    - require:
      - file: salt.minion restart_minion.sh script
    - order: last
