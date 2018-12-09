base:
  '*':
    - common
    - ssh.sshd
    - user
  'roles:salt-prime':
    - match: pillar
    - salt.prime
