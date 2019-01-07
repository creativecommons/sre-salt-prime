include:
  - stunnel4


# Connectivity testing and troubleshooting - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9190869
#
# Secure LDAP schema - Cloud Identity Help
# https://support.google.com/cloudidentity/answer/9188164


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
    - mode: 0444
    - require:
      - pkg: stunnel4 installed packages
      - file: pmwiki.ldap google ldap cert
      - file: pmwiki.ldap google ldap key
    - watch_in:
      - service: stunnel4 service
