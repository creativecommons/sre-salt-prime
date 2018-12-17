# This state assumes Debian 9 (Stretch). For each section below, the stanzas
# are in order they appear in /etc/ssh/sshd_config.


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - openssh-server


service_ssh:
  service.running:
    - name: ssh
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


### Changes


{{ sls }} decrease LoginGraceTime:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*LoginGraceTime .*
    - repl: LoginGraceTime 30s
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is 120 seconds.
    - append_if_not_found: True
    - watch_in:
      - service: service_ssh


{{ sls }} disable PermitRootLogin:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*PermitRootLogin .*
    - repl: PermitRootLogin no
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is prohibit-password.
    - append_if_not_found: True
    - watch_in:
      - service: service_ssh


# TCPKeepAlive is disabled in favor of ClientAliveInterval and
# ClientAliveCountMax. TCPKeepAlive too often results in disruption due to
# WiFi roaming and route flaps.
{{ sls }} disable TCPKeepAlive:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*TCPKeepAlive .*
    - repl: TCPKeepAlive no
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is yes
    - append_if_not_found: True
    - watch_in:
      - service: service_ssh


# A ClientAliveInterval of 30s combined with a ClientAliveCountMax of 60 will
# result in disconnections of unresponsive clients after half an hour.
#
# The relatively short ClientAliveInterval should ensure aggressive TTLs do not
# severe connections. The larger ClientAliveCountMax should allow brief
# interruptions without disrupting work.
{{ sls }} set ClientAliveInterval:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*ClientAliveInterval .*
    - repl: ClientAliveInterval 30s
    - count: 1
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is 0
    - append_if_not_found: True
    - watch_in:
      - service: service_ssh
    - require:
      - file: {{ sls }} remove 1st trailing ClientAliveInterval
      - file: {{ sls }} remove 2nd trailing ClientAliveInterval


{{ sls }} set ClientAliveCountMax:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*ClientAliveCountMax .*
    - repl: ClientAliveCountMax 60
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is 3
    - append_if_not_found: True
    - watch_in:
      - service: service_ssh


{{ sls }} remove 1st trailing ClientAliveInterval:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: ClientAliveInterval 420
    - mode: delete
    - watch_in:
      - service: service_ssh


{{ sls }} remove 2nd trailing ClientAliveInterval:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: ClientAliveInterval 120
    - mode: delete
    - watch_in:
      - service: service_ssh


{{ sls }} append group sudo StreamLocalBindUnlink:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: |

        Match Group sudo
            StreamLocalBindUnlink yes
    - watch_in:
      - service: service_ssh


### Ensure Authentication Defaults


{{ sls }} ensure PubkeyAuthentication is enabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *PubkeyAuthentication .*
    - repl: '#PubkeyAuthentication yes'
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is yes.
    - append_if_not_found: False
    - watch_in:
      - service: service_ssh


{{ sls }} ensure PasswordAuthentication is disabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *PasswordAuthentication .*
    - repl: PasswordAuthentication no
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is no.
    - append_if_not_found: False
    - watch_in:
      - service: service_ssh


{{ sls }} ensure ChallengeResponseAuthentication is disabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *ChallengeResponseAuthentication .*
    - repl: ChallengeResponseAuthentication no
    - flags:
      - IGNORECASE
      - MULTILINE
    # The default is no.
    - append_if_not_found: False
    - watch_in:
      - service: service_ssh
