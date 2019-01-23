# Minion upgrade is not included on the salt-prime server. On the salt-prime
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


{% set target = pillar["salt"]["minion_target_version"] -%}
{{ sls }} upgrade minion:
  cmd.run:
    - name: nohup /usr/local/sbin/upgrade_minion.sh {{ target }}
    - bg: True
    - onlyif: /usr/local/sbin/minion_upgraded_needed.sh {{ target }}
    - require:
      - file: {{ sls }} minion_upgraded_needed.sh script
      - file: {{ sls }} upgrade_minion.sh script
      - pkg: {{ sls }} installed packages
    - order: last


{% endif -%}


{{ sls }} salt-doc:
  pkg:
    - purged
{% if not (salt.match.glob("salt-prime__*")) %}{{ "    " -}}
    - require:
      - cmd: {{ sls }} upgrade minion
{%- endif %}


{{ sls }} restart_minion.sh script:
  file.managed:
    - name: /usr/local/sbin/restart_minion.sh
    - source: salt://salt/files/restart_minion.sh
    - mode: '0555'
    - follow_symlinks: False


{{ sls }} restart minion:
  cmd.run:
    - name: nohup /usr/local/sbin/restart_minion.sh
    - bg: True
    - require:
      - file: {{ sls }} restart_minion.sh script
    - order: last


{{ sls }} minion config file:
  file.managed:
    - name: /etc/salt/minion.d/salt_minion.conf
    - source: salt://salt/files/salt_minion.conf
    - mode: '0444'
    - template: jinja
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages
    - onchanges_in:
      - cmd: {{ sls }} restart minion


{{ sls }} file/pillar roots config file:
  file.managed:
    - name: /etc/salt/minion.d/file-pillar_roots.conf
    - source: salt://salt/files/file-pillar_roots.conf
    - mode: '0444'
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages
    - onchanges_in:
      - cmd: {{ sls }} restart minion


{% if grains.manufacturer == "Amazon EC2" -%}
{{ sls }} metadata_server_grains config file:
  file.managed:
    - name: /etc/salt/minion.d/metadata_server_grains.conf
    - contents:
      - 'metadata_server_grains: True'
      - ''
      - '# vim: ft=yaml'
    - mode: '0444'
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages
    - onchanges_in:
      - cmd: {{ sls }} restart minion


{% else %}
{{ sls }} metadata_server_grains config file:
  file.absent:
    - name: /etc/salt/minion.d/metadata_server_grains.conf
    - follow_symlinks: False
    - require:
      - pkg: {{ sls }} installed packages
    - onchanges_in:
      - cmd: {{ sls }} restart minion


{% endif %}
