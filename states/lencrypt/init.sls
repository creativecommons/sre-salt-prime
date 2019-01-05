include:
  - letsencrypt


{{ sls }} debianize letsencrypt archive dirs:
  file.directory:
    - name: /etc/letsencrypt/archive
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'


{{ sls }} debianize letsencrypt live dirs:
  file.directory:
    - name: /etc/letsencrypt/live
    - group: ssl-cert
    - recurse:
      - group
      - mode
    - dir_mode: '2710'
    - file_mode: '0640'
