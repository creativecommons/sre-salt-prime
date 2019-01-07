include:
  - stunnel4.google_ldap


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - ldap-utils


{{ sls }} google ldap cert:
  file.managed:
    - name: /etc/stunnel/Google_2022_01_04_62076.crt
    - source: salt://pmwiki/files/Google_2022_01_04_62076.crt
    - mode: '0444'
    - user: stunnel4
    - group: stunnel4


{{ sls }} google ldap key:
  file.managed:
    - name: /etc/stunnel/Google_2022_01_04_62076.key
    - source: salt://pmwiki/files/Google_2022_01_04_62076.key
    - mode: '0400'
    - user: stunnel4
    - group: stunnel4
