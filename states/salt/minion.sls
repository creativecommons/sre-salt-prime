# Minion restart is not included on the salt-prime server. On the salt-prime
# server the salt packages should be upgraded manually (and then
# minion_target_version pillar updated).


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - salt-minion


{% if not (salt.match.glob("salt-prime__*")) -%}

{{ sls }} minion_upgraded_needed.sh script:
  file.managed:
    - name: /usr/local/sbin/minion_upgraded_needed.sh
    - source: salt://salt/files/minion_upgraded_needed.sh
    - mode: '0555'
    - follow_symlinks: False


{{ sls }} upgrade_minion.sh script:
  file.managed:
    - name: /usr/local/sbin/upgrade_minion.sh
    - source: salt://salt/files/upgrade_minion.sh
    - mode: '0555'
    - follow_symlinks: False


{{ sls }} restart_minion.sh script:
  file.managed:
    - name: /usr/local/sbin/restart_minion.sh
    - source: salt://salt/files/restart_minion.sh
    - mode: '0555'
    - follow_symlinks: False


{% set target = pillar["salt"]["minion_target_version"] -%}
{{ sls }} upgrade minion:
  cmd.run:
    - name: nohup /usr/local/sbin/upgrade_minion.sh {{ target }} &
    - onlyif: /usr/local/sbin/minion_upgraded_needed.sh {{ target }}
    - require:
      - file: {{ sls }} minion_upgraded_needed.sh script
      - file: {{ sls }} upgrade_minion.sh script
      - pkg: {{ sls }} installed packages
    - order: last


{{ sls }} restart minion:
  cmd.run:
    - name: nohup /usr/local/sbin/restart_minion.sh &
    - onchanges:
      - file: {{ sls }} minion config file
      - file: {{ sls }} file/pillar roots config file
    - require:
      - file: {{ sls }} restart_minion.sh script
    - order: last

{% endif %}


{{ sls }} salt-doc:
  pkg:
    - purged  {# fix whitespace -#}
{% if not (salt.match.glob("salt-prime__*")) %}
    - require:
      - cmd: {{ sls }} upgrade minion
{% endif %}


{{ sls }} minion config file:
  file.managed:
    - name: /etc/salt/minion.d/salt_minion.conf
    - source: salt://salt/files/salt_minion.conf
    - mode: '0444'
    - template: jinja
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} file/pillar roots config file:
  file.managed:
    - name: /etc/salt/minion.d/file-pillar_roots.conf
    - source: salt://salt/files/file-pillar_roots.conf
    - mode: '0444'
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages
