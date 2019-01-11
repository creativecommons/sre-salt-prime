include:
  - stunnel4


# Connectivity testing and troubleshooting - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9190869
#
# Secure LDAP schema - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9188164


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
    - require:
      - pkg: stunnel4 installed packages


{{ sls }} google ldap key:
  file.managed:
    - name: /etc/stunnel/Google_2022_01_04_62076.key
    - source: salt://pmwiki/files/Google_2022_01_04_62076.key
    - mode: '0440'
    - user: stunnel4
    - group: stunnel4
    - require:
      - pkg: stunnel4 installed packages


{{ sls }} /etc/stunnel/google-ldap.conf:
  file.managed:
    - name: /etc/stunnel/google_ldap.conf
    - contents:
      - '[ldap]'
      - client = yes
      - accept = 127.0.0.1:1636
      - connect = ldap.google.com:636
      - cert = /etc/stunnel/Google_2022_01_04_62076.crt
      - key = /etc/stunnel/Google_2022_01_04_62076.key
      - setuid = stunnel4
      - setgid = stunnel4
    - mode: '0444'
    - require:
      - file: {{ sls }} google ldap cert
      - file: {{ sls }} google ldap key
    - watch_in:
      - service: stunnel4 service
