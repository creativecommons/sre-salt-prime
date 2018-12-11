/usr/local/sbin/minion_upgraded_needed.sh:
  file.managed:
    - source: salt://salt/files/minion_upgraded_needed.sh
    - mode: '0555'
    - follow_symlinks: False

/usr/local/sbin/upgrade_minion.sh:
  file.managed:
    - source: salt://salt/files/upgrade_minion.sh
    - mode: '0555'
    - follow_symlinks: False

{% set target = pillar["salt"]["minion_target_version"] -%}
{{ sls }} upgrade minion:
  cmd.run:
    - name: nohup /usr/local/sbin/upgrade_minion.sh {{ target }} &
    - onlyif: /usr/local/sbin/minion_upgraded_needed.sh {{ target }}
    - require:
      - file: /usr/local/sbin/minion_upgraded_needed.sh
      - file: /usr/local/sbin/upgrade_minion.sh
    - order: last

salt-doc:
  pkg:
    - purged
    - require:
      - cmd: {{ sls }} upgrade minion
