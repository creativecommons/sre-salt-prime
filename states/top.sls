base:
  '*':
    - common
    - ssh.sshd
    - user
  'roles:salt-prime':
    - match: pillar
    - salt.prime
  'virtual:kvm':
    - match: grain
    - common.virtual
