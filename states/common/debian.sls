{{ sls }} sources file:
  file.managed:
    - name: /etc/apt/sources.list.d/debian.sources
    - source: salt://common/files/debian.sources
    - mode: '0444'
    - template: jinja
    - defaults:
        CODENAME: {{ grains["lsb_distrib_codename"] }}
        SLS: {{ sls }}


{{ sls }} remove legacy sources file:
  file.managed:
    - name: /etc/apt/sources.list
    - contents:
        - '# Managed by SaltStack: common.debian'
        - '#'
        - '# See /etc/apt/sources.list.d/debian.source, etc.'
    - require:
        - file: {{ sls }} sources file
