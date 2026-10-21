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
    # Debian wants an empty file here ¯\_(ツ)_/¯
    - content:
    - require:
        - file: {{ sls }} sources file
