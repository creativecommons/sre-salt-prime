{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - stunnel4


{{ sls }} service:
  service.running:
    - name: stunnel4
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} default enabled:
  file.replace:
    - name: /etc/default/stunnel4
    - pattern: ^ENABLED=0
    - repl: ENABLED=1
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is 0 (disabled)
    - append_if_not_found: False
    - watch_in:
      - service: {{ sls }} service

{#
{{ sls }} global.conf:
  file.managed:
    - name: /etc/stunnel/global.conf
    - contents:
      - options = NO_SSLv2
      - options = NO_SSLv3
      - options = NO_TLSv1
      - options = NO_TLSv1.1
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service
#}
