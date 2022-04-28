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
    - name: /etc/stunnel/Google_2025_04_25_75409.crt
    - source: salt://stunnel4/files/Google_2025_04_25_75409.crt
    - mode: '0444'
    - user: stunnel4
    - group: stunnel4
    - require:
      - pkg: stunnel4 installed packages


{{ sls }} google ldap key:
  file.managed:
    - name: /etc/stunnel/Google_2025_04_25_75409.key
    - source: salt://stunnel4/files/Google_2025_04_25_75409.key
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
      - cert = /etc/stunnel/Google_2025_04_25_75409.crt
      - key = /etc/stunnel/Google_2025_04_25_75409.key
      - setuid = stunnel4
      - setgid = stunnel4
    - mode: '0444'
    - require:
      - file: {{ sls }} google ldap cert
      - file: {{ sls }} google ldap key
    - watch_in:
      - service: stunnel4 service


{{ sls }} install test_google_ldap.sh:
  file.managed:
    - name: /usr/local/sbin/test_google_ldap.sh
    - source: salt://stunnel4/files/test_google_ldap.sh
    - mode: '0550'
    - template: jinja
    - defaults:
        slspath: {{ slspath }}
