include:
  - letsencrypt


{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - ssl-cert


{{ sls }} debianize letsencrypt archive dirs:
  file.directory:
    - name: /etc/letsencrypt/archive
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'
    - require:
      - pkg: {{ sls }} dependencies


{{ sls }} debianize letsencrypt live dirs:
  file.directory:
    - name: /etc/letsencrypt/live
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'
    - require:
      - pkg: {{ sls }} dependencies
