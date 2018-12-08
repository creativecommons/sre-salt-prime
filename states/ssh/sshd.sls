# This state assumes Debian 9 (Stretch). For each section below, the stanzas
# are in order they appear in /etc/ssh/sshd_config.

ssh_service:
  service.running:
    - name: ssh


### Changes


sshd decrease LoginGraceTime:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*LoginGraceTime .*
    - repl: LoginGraceTime 30s
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is 120 seconds.
    - append_if_not_found: True
    - backup: False
    - watch_in:
        - service: ssh_service

sshd disable PermitRootLogin:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*PermitRootLogin .*
    - repl: PermitRootLogin no
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is prohibit-password.
    - append_if_not_found: True
    - backup: False
    - watch_in:
        - service: ssh_service

# TCPKeepAlive is disabled in favor of ClientAliveInterval and
# ClientAliveCountMax. TCPKeepAlive too often results in disruption due to
# WiFi roaming and route flaps.
sshd disable TCPKeepAlive:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*TCPKeepAlive .*
    - repl: TCPKeepAlive no
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is yes
    - append_if_not_found: True
    - backup: False
    - watch_in:
        - service: ssh_service

# A ClientAliveInterval of 30s combined with a ClientAliveCountMax of 60 will
# result in disconnections of unresponsive clients after half an hour.
#
# The relatively short ClientAliveInterval should ensure aggresive TTLs do not
# severe connections. The larger ClientAliveCountMax should allow brief
# interruptions without disrupting work.
sshd set ClientAliveInterval:
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
    - backup: False
    - watch_in:
        - service: ssh_service
    - require:
        - file: sshd remove 1st trailing ClientAliveInterval
        - file: sshd remove 2nd trailing ClientAliveInterval

sshd set ClientAliveCountMax:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^[# ]*ClientAliveCountMax .*
    - repl: ClientAliveCountMax 60
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is 3
    - append_if_not_found: True
    - backup: False
    - watch_in:
        - service: ssh_service

sshd remove 1st trailing ClientAliveInterval:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: ClientAliveInterval 420
    - mode: delete
    - backup: False
    - watch_in:
        - service: ssh_service

sshd remove 2nd trailing ClientAliveInterval:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: ClientAliveInterval 120
    - mode: delete
    - backup: False
    - watch_in:
        - service: ssh_service


### Ensure Authentication Defaults


sshd ensure PubkeyAuthentication is enabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *PubkeyAuthentication .*
    - repl: '#PubkeyAuthentication yes'
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is yes.
    - append_if_not_found: False
    - backup: False
    - watch_in:
        - service: ssh_service

sshd ensure PasswordAuthentication is disabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *PasswordAuthentication .*
    - repl: PasswordAuthentication no
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is no.
    - append_if_not_found: False
    - backup: False
    - watch_in:
        - service: ssh_service

sshd ensure ChallengeResponseAuthentication is disabled:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^ *ChallengeResponseAuthentication .*
    - repl: ChallengeResponseAuthentication no
    - flags:
        - IGNORECASE
        - MULTILINE
    # The default is no.
    - append_if_not_found: False
    - backup: False
    - watch_in:
        - service: ssh_service
